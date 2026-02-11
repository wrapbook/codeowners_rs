use crate::rule::Rule;
use magnus::{Error, Ruby};
use regex::Captures;
use regex::Regex;
use regex::RegexSet;
use regex::RegexSetBuilder;
use std::borrow::Cow;
use std::fs;
use std::sync::LazyLock;

#[derive(Clone, Debug)]
#[magnus::wrap(class = "CodeownersRs::Ruleset")]
pub struct Ruleset {
    path: Option<String>,
    root: String,
    rules: Vec<Rule>,
    regex_set: RegexSet,
}

const REGEX_SET_NEST_LIMIT: u32 = 100;
const REGEX_SET_DFA_SIZE_LIMIT: usize = 10_048_576; // 10MB

impl Ruleset {
    pub fn load(ruby: &Ruby, path: String, root: Option<String>) -> Result<Self, Error> {
        let content = fs::read_to_string(&path).map_err(|e| {
            Error::new(
                Ruby::exception_runtime_error(ruby),
                format!("Failed to read file: {}", e),
            )
        })?;

        Ok(Self::build(
            content,
            root.unwrap_or_else(|| Self::inferred_root_from_path(&path)),
            Some(path),
        ))
    }

    pub fn build(content: String, root: String, path: Option<String>) -> Self {
        let root = root.trim_end_matches('/').to_string();
        let rules = content
            .lines()
            .enumerate()
            .filter_map(|(line_number, line)| Rule::from_line_str(line, line_number + 1))
            .collect::<Vec<Rule>>();
        let regex_set = RegexSetBuilder::new(
            rules
                .iter()
                .map(|rule| pattern_to_regex_string(rule.pattern())),
        )
        .dfa_size_limit(REGEX_SET_DFA_SIZE_LIMIT)
        .nest_limit(REGEX_SET_NEST_LIMIT)
        .build()
        .unwrap();

        Self {
            path,
            root,
            rules,
            regex_set,
        }
    }

    pub fn default_rule(&self) -> Option<Rule> {
        self.rules
            .iter()
            .find(|rule| rule.pattern() == "*")
            .cloned()
    }

    pub fn rule_for_path(&self, path: String) -> Option<Rule> {
        let normalized_path = normalize_path(&path, &self.root);

        // Last matching wins
        self.regex_set
            .matches(&normalized_path)
            .iter()
            .last()
            .map(|idx| self.rules[idx].clone())
    }

    pub fn owners_for_path(&self, path: String) -> Vec<String> {
        if let Some(rule) = self.rule_for_path(path) {
            rule.owners()
        } else {
            vec![]
        }
    }

    pub fn path(&self) -> Option<&str> {
        self.path.as_deref()
    }

    pub fn root(&self) -> &str {
        &self.root
    }

    pub fn rules(&self) -> Vec<Rule> {
        self.rules.clone()
    }

    // To use a CODEOWNERS file, create a new file called CODEOWNERS in the .github/, root, or docs/ directory of the repository
    fn inferred_root_from_path(path: &str) -> String {
        if path.ends_with("/.github/CODEOWNERS") {
            path.trim_end_matches("/.github/CODEOWNERS").to_string()
        } else if path.ends_with("/docs/CODEOWNERS") {
            path.trim_end_matches("/docs/CODEOWNERS").to_string()
        } else {
            path.trim_end_matches("/CODEOWNERS").to_string()
        }
    }
}

// Replace CODEOWNERS pattern captures with regex equivalents
static REPLACEMENT_REGEX: LazyLock<Regex> = LazyLock::new(|| {
    let re_str = [
        regex::escape("/**/"),
        regex::escape("**"),
        regex::escape("*"),
        regex::escape("/"),
        regex::escape("."),
    ]
    .join("|");
    return Regex::new(&re_str).unwrap();
});

fn replace_piece(piece: &str) -> &'static str {
    match piece {
        "/**/" => "[^.]*/",
        "**" => ".*",
        "*" => "[^/]*",
        "/" => r"\/",
        "." => r"\.",
        other => panic!("No regex mapping for '{}'", other),
    }
}

fn pattern_to_regex_string(pattern: &str) -> String {
    let mut regex_str = pattern.to_string();

    // Replace prefix "/" with "\\A/"
    if regex_str.starts_with('/') {
        regex_str.insert_str(0, r"\A");
    }

    // Replace suffix "/*" with "/*\\z"
    if regex_str.ends_with("/*") {
        regex_str.push_str(r"\z");
    }

    // Replace suffix "/**" with "/**\\z"
    if regex_str.ends_with("/**") {
        regex_str.push_str(r"\z");
    }

    // Replace CODEOWNERS patterns with regex equivalents
    REPLACEMENT_REGEX
        .replace_all(&regex_str, |caps: &Captures| {
            replace_piece(caps.get(0).unwrap().as_str())
        })
        .into_owned()
}

fn normalize_path<'a>(path: &'a str, root: &str) -> Cow<'a, str> {
    let trimmed = path.trim_start_matches(root);
    if trimmed.starts_with('/') {
        Cow::Borrowed(trimmed)
    } else {
        Cow::Owned(format!("/{}", trimmed))
    }
}
