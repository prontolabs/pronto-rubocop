# Pronto runner for Rubocop

[![Code Climate](https://codeclimate.com/github/mmozuras/pronto-rubocop.png)](https://codeclimate.com/github/mmozuras/pronto-rubocop)
[![Build Status](https://travis-ci.org/mmozuras/pronto-rubocop.png)](https://travis-ci.org/mmozuras/pronto-rubocop)
[![Gem Version](https://badge.fury.io/rb/pronto-rubocop.png)](http://badge.fury.io/rb/pronto-rubocop)
[![Dependency Status](https://gemnasium.com/mmozuras/pronto-rubocop.png)](https://gemnasium.com/mmozuras/pronto-rubocop)

Pronto runner for [Rubocop](https://github.com/bbatsov/rubocop), ruby code analyzer. [What is Pronto?](https://github.com/mmozuras/pronto)

## Configuration

Configuring Rubocop via .rubocop.yml will work just fine with pronto-rubocop.
You can also specify a custom `.rubocop.yml` location with the environment variable `RUBOCOP_CONFIG`

You can also provide additional configuration via `.pronto.yml`:

    rubocop:
      # Auto-correct issues
      auto-correct: true
