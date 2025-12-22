use magnus::{function, method, prelude::*, Error, Module, Ruby};

mod rule;
mod ruleset;

use rule::Rule;
use ruleset::Ruleset;

// https://github.com/matsadler/magnus/issues/66
unsafe impl magnus::IntoValueFromNative for Rule {}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = Ruby::define_module(ruby, "CodeownersRs")?;

    let class = module.define_class("Ruleset", ruby.class_object())?;
    class.define_singleton_method("load", function!(Ruleset::load, 2))?;
    class.define_singleton_method("build", function!(Ruleset::build, 3))?;
    class.define_method("default_rule", method!(Ruleset::default_rule, 0))?;
    class.define_method("rule_for_path", method!(Ruleset::rule_for_path, 1))?;
    class.define_method("owners_for_path", method!(Ruleset::owners_for_path, 1))?;
    class.define_method("path", method!(Ruleset::path, 0))?;
    class.define_method("root", method!(Ruleset::root, 0))?;
    class.define_method("rules", method!(Ruleset::rules, 0))?;

    let class = module.define_class("Rule", ruby.class_object())?;
    class.define_singleton_method("new", function!(Rule::new, 3))?;
    class.define_singleton_method("from_line", function!(Rule::from_line, 2))?;
    class.define_method("match?", method!(Rule::is_match, 1))?;
    class.define_method("pattern", method!(Rule::pattern, 0))?;
    class.define_method("regex_string", method!(Rule::regex_string, 0))?;
    class.define_method("owners", method!(Rule::owners, 0))?;
    class.define_method("line_number", method!(Rule::line_number, 0))?;

    Ok(())
}
