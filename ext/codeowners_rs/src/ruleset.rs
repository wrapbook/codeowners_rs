use crate::rule::Rule;
use magnus::{Error, Ruby};
use std::fs;

#[derive(Clone, Debug)]
#[magnus::wrap(class = "CodeownersRs::Ruleset")]
pub struct Ruleset {
    path: Option<String>,
    root: String,
    rules: Vec<Rule>,
}

impl Ruleset {
    pub fn load(ruby: &Ruby, path: String, root: String) -> Result<Self, Error> {
        let content = fs::read_to_string(&path).map_err(|e| {
            Error::new(
                Ruby::exception_runtime_error(ruby),
                format!("Failed to read file: {}", e),
            )
        })?;

        Ok(Self::build(content, root, Some(path)))
    }

    pub fn build(content: String, root: String, path: Option<String>) -> Self {
        let root = root.trim_end_matches('/').to_string();
        let rules = content
            .lines()
            .enumerate()
            .filter_map(|(line_number, line)| Rule::from_line_str(line, line_number + 1))
            .collect::<Vec<Rule>>();

        Self { path, root, rules }
    }

    pub fn default_rule(&self) -> Option<Rule> {
        self.rules
            .iter()
            .find(|rule| rule.pattern() == "*")
            .cloned()
    }

    pub fn rule_for_path(&self, path: String) -> Option<Rule> {
        let mut normalized_path = path.trim_start_matches(&self.root).to_string();
        if !normalized_path.starts_with("/") {
            normalized_path.insert_str(0, "/");
        }

        // Search in reverse order (last matching rule wins)
        return self
            .rules
            .iter()
            .rfind(|rule| rule.is_match_str(&normalized_path))
            .cloned();
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
}
