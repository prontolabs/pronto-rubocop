# Pronto runner for RuboCop

[![Gem Version](https://badge.fury.io/rb/pronto-rubocop.png)](http://badge.fury.io/rb/pronto-rubocop)
[![Build Status](https://github.com/prontolabs/pronto-rubocop/actions/workflows/checks.yml/badge.svg)](https://github.com/prontolabs/pronto-rubocop/actions/workflows/checks.yml)
[![Code Climate](https://codeclimate.com/github/prontolabs/pronto-rubocop.png)](https://codeclimate.com/github/prontolabs/pronto-rubocop)

Pronto runner for [RuboCop](https://github.com/bbatsov/rubocop), ruby code
analyzer. [What is Pronto?](https://github.com/prontolabs/pronto)

- [Configuration](#configuration)
- [Usage](#usage)
- [Suggestions](#suggestions)
- [Only patched lines](#only-patched-lines)
- [RuboCop versions](#rubocop-versions)

## Configuration

Configuring RuboCop via `.rubocop.yml` will work just fine with
`pronto-rubocop`.

You can also specify a custom `.rubocop.yml` location with the environment
variable `RUBOCOP_CONFIG`.

You can also provide additional configuration via `.pronto.yml`:

```yml
rubocop:
  # Map of RuboCop severity level to Pronto severity level
  severities:
    refactor: info
    warning: error

  # Enable suggestions
  suggestions: true

  # Only report warnings on added/modified lines of code
  # You can provide a number for a range to catch warnings on lines that were not modified
  only_patched_lines:
    enabled: false # default
    range: 0 # default
```

## Suggestions

When suggestions are enabled, the messages will include a line suggesting
what to change, using [GitHub's](https://twitter.com/wa7son/status/1052326282900443137)
syntax on Pull Request reviews, that can be approved in one click right from
the Pull Request.

For example:

![GitHub screenshot with suggestion](https://user-images.githubusercontent.com/132/50402757-1bd75b80-0799-11e9-809f-8b8a23ed33f6.png)

## Only patched lines

When `only_patched_lines` is enabled, Rubocop warnings that start outside of the patched code will be ignored.
For example, if you add a method to a class with too many lines, the warning at the class level will not apply.

This can be useful for legacy applications with a lot of RuboCop warnings, where you want to focus on the new code.

When increasing the range, you will also catch warnings on lines that were not modified but are within the range of the modified lines.

For example, if you set `range: 1`, you will catch warnings starting before the patched lines, but only if they are within 1 line.

```ruby
# With `only_patched_lines` enabled and a default range of 1, the Metrics/ClassLength warning is not included in the results.
# However, when `range` is increased to 10, now Metrics/ClassLength will be included alongside the Metrics/MethodLength warning for the `too_long` method.
class TooLong
  def just_fine
    "I'm doing just fine, how about you?"
  end

  def too_long
    # Pretend I am a new method that's 32 lines long.
  end
end
```

## RuboCop versions

If you need to use RuboCop v0.84.0 or v0.85.x, you'll need to ensure that
you've also added `gem 'rubocop-ast', '< 0.7.0'` to your Gemfile as
these were the first versions to use rubocop-ast, and unfortunately the
dependency was loose enough that rubocop-ast versions >= 0.7.0 were allowed,
which causes `require 'rubocop'` to fail with
```
  NoMethodError:
    undefined method `join' for #<Set: {:==, :===, :!=, :<=, :>=, :>, :<}>
  in rubocop-0.84.0/lib/rubocop/cop/style/redundant_conditional.rb:57:in `<class:RedundantConditional>'
```
This is due to https://github.com/rubocop-hq/rubocop-ast/issues/22
