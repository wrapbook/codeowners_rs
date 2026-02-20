# CodeownersRs

[![Ruby](https://github.com/wrapbook/codeowners_rs/actions/workflows/test.yml/badge.svg)](https://github.com/wrapbook/codeowners_rs/actions/workflows/test.yml?event=push)

## Installation

```ruby
gem "codeowners_rs"
```

## Usage

```ruby
codeowners = CodeownersRs.load("/path/to/CODEOWNERS")
codeowners.rule_for_path("app/models/user.rb")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake compile` to compile the Rust code. Run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Releasing

To create a new release, push a new version tag to GitHub. The `release.yml` workflow takes care of cross compilation and pushing to RubyGems.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wrapbook/codeowners_rs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Disclaimer

This project is provided as open source under the MIT License and is made available on an **"as is"** basis, without warranty of any kind, express or implied.

This repository is **not an official Wrapbook product**. Wrapbook makes no commitments regarding ongoing development, maintenance, bug fixes, security updates, or compatibility.

Use of this project is at your own risk.
