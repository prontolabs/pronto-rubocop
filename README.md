# Pronto runner for RuboCop

[![Code Climate](https://codeclimate.com/github/prontolabs/pronto-rubocop.png)](https://codeclimate.com/github/prontolabs/pronto-rubocop)
[![Build Status](https://travis-ci.org/prontolabs/pronto-rubocop.svg?branch=master)](https://travis-ci.org/prontolabs/pronto-rubocop)
[![Gem Version](https://badge.fury.io/rb/pronto-rubocop.png)](http://badge.fury.io/rb/pronto-rubocop)

Pronto runner for [RuboCop](https://github.com/bbatsov/rubocop), ruby code
analyzer. [What is Pronto?](https://github.com/prontolabs/pronto)

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
```

## Suggestions

When suggestions are enabled, the messages will include a line suggesting
what to change, using [GitHub's](https://twitter.com/wa7son/status/1052326282900443137)
syntax on Pull Request reviews, that can be approved in one click right from
the Pull Request.

For example:

![GitHub screenshot with suggestion](https://user-images.githubusercontent.com/132/50402757-1bd75b80-0799-11e9-809f-8b8a23ed33f6.png)

## RuboCop versions

If you need to use RuboCop v0.84.0 or v0.85.x, you'll need to ensure that
you've also need to add `gem 'rubocop-ast', '< 0.7.0'` to your Gemfile as
these were the first versions to use rubocop-ast, and unfortunately the
dependency was loose enough that rubocop-ast versions >= 0.7.0 were allowed,
which causes `require 'rubocop'` to fail with
```
  NoMethodError:
    undefined method `join' for #<Set: {:==, :===, :!=, :<=, :>=, :>, :<}>
  in rubocop-0.84.0/lib/rubocop/cop/style/redundant_conditional.rb:57:in `<class:RedundantConditional>'
```
This is due to https://github.com/rubocop-hq/rubocop-ast/issues/22
