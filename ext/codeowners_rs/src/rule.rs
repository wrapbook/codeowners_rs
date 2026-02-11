#[derive(Clone, Debug)]
#[magnus::wrap(class = "CodeownersRs::Rule")]
pub struct Rule {
    pattern: String,
    owners: Vec<String>,
    line_number: usize,
}

impl Rule {
    pub fn new(pattern: String, owners: Vec<String>, line_number: usize) -> Self {
        Self {
            pattern,
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

    pub fn pattern(&self) -> &str {
        &self.pattern
    }

    pub fn owners(&self) -> Vec<String> {
        self.owners.clone()
    }

    pub fn line_number(&self) -> usize {
        self.line_number
    }
}
