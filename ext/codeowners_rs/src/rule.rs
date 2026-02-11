use regex::Captures;
use regex::Regex;
use std::sync::LazyLock;

#[derive(Clone, Debug)]
#[magnus::wrap(class = "CodeownersRs::Rule")]
pub struct Rule {
    pattern: String,
    regex: Regex,
    owners: Vec<String>,
    line_number: usize,
}

impl Rule {
    pub fn new(pattern: String, owners: Vec<String>, line_number: usize) -> Self {
        let regex = pattern_to_regex(&pattern);
        Self {
            pattern,
            regex,
            owners,
            line_number,
        }
    }

    pub fn from_line(line: String, line_number: usize) -> Option<Self> {
        Self::from_line_str(&line, line_number)
    }

    pub fn from_line_str(line: &str, line_number: usize) -> Option<Self> {
        let rule_string = line.split('#').next().unwrap_or(""); // Remove comments
        let parts = rule_string.split_whitespace().collect::<Vec<&str>>();
        match parts.as_slice() {
            [] => None,
            [pattern, owners @ ..] => Some(Self::new(
                pattern.to_string(),
                owners.iter().map(|s| s.to_string()).collect(),
                line_number,
            )),
        }
    }

    pub fn is_match(&self, path: String) -> bool {
        self.regex.is_match(&path)
    }

    pub fn is_match_str(&self, path: &str) -> bool {
        self.regex.is_match(path)
    }

    pub fn pattern(&self) -> &str {
        &self.pattern
    }

    pub fn owners(&self) -> Vec<String> {
        self.owners.clone()
    }

    pub fn line_number(&self) -> usize {
        self.line_number
    }

    // for testing/debugging
    pub fn regex_string(&self) -> &str {
        self.regex.as_str()
    }
}

// Replace CODEOWNERS pattern captures with regex equivalents
static REPLACEMENT_REGEX: LazyLock<Regex> = LazyLock::new(|| {
    let re_str = [
        regex::escape("/**/"),
        regex::escape("/**"),
        regex::escape("*+"),
        regex::escape("*"),
        regex::escape("/"),
        regex::escape("."),
    ]
    .join("|");
    return Regex::new(&re_str).unwrap();
});

fn replace_piece(piece: &str) -> &'static str {
    match piece {
        "/**/" => "/[^.]*/",
        "/**" => "/.*",
        "*+" => ".*",
        "*" => "[^/]*",
        "/" => r"\/",
        "." => r"\.",
        other => panic!("No regex mapping for '{}'", other),
    }
}

fn pattern_to_regex(pattern: &str) -> Regex {
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
    regex_str = REPLACEMENT_REGEX
        .replace_all(&regex_str, |caps: &Captures| {
            replace_piece(caps.get(0).unwrap().as_str())
        })
        .to_string();

    // println!("Converted pattern '{}' to regex '{}'", pattern, regex_str);

    match Regex::new(&regex_str) {
        Ok(r) => r,
        Err(e) => panic!("Failed to compile regex from pattern '{}': {}", pattern, e),
    }
}
