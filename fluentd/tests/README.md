
# AWSPEC

## How to run
# Simple Test with AWSpec

This directory contains the first example of how we can test our infra before releasing it to teams.

We are using the rspec framework and thew [awspec](https://github.com/k1LoW/awspec) library. 

[Resource types](https://github.com/k1LoW/awspec/blob/master/doc/resource_types.md) we can test

## Pipeline Testing

```yaml
      - Test:
          environment_variables:
            AWS_PROFILE: compliance
            AWS_REGION: eu-central-1
          jobs:
            AWSSpec:
              resources:
                - compliance
              tasks:
                - exec:
                    run_if: passed
                    working_directory: terraform/define-roles/tests
                    command: /bin/bash
                    arguments:
                      - -c
                      - >
                        bundle install
                - exec:
                    run_if: passed
                    working_directory: terraform/define-roles/tests
                    command: /bin/bash
                    arguments:
                      - -c
                      - >
                        bundle exec rspec --format documentation
```

## Manual testing

How to run a test from the compliance agents

```bash
cd tests directory
bundle install
AWS_REGION=eu-central-1 AWS_PROFILE=compliance bundle exec rspec
```

## Structure
```bash
tests      
├── Gemfile (just copy paste)
├── Gemfile.lock (just copy paste, this pins the local versions to match the agents)
├── README.md (just copy paste)
└── spec
    ├── roles_spec.rb (your tests - can be multiple files)
    └── spec_helper.rb (just copy paste)
```
## Docs

Need some help - have a look at the [resource types](https://github.com/k1LoW/awspec/blob/master/doc/resource_types.md)
