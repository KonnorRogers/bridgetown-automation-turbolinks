# Purpose

To provide an easy way for users to add Docker to their project.

## Prerequisites

- Ruby >= 2.5
- Bridgetown ~> 0.15.0
- Docker
- Docker Compose

```bash
bridgetown -v
# => bridgetown 0.15.0.beta3 "Overlook"

docker -v
# Docker version 19.03.8, build afacb8b7f0

docker-compose -v
# docker-compose version 1.25.0, build unknown
```

This project requires the new `apply` command introduced in Bridgetown
`0.15.0`

## Usage

### New project

```bash
bridgetown new <newsite> --apply="https://github.com/ParamagicDev/bridgetown-automation-docker-compose"
```

### Existing Project

```bash
[bundle exec] bridgetown apply https://github.com/ParamagicDev/bridgetown-automation-docker-compose
```

## Getting Started

### Linux

Prior to running `docker-compose up --build` or `docker-compose build`
make sure to `source` the `docker.env` file to prevent permissions
issues.

`source ./docker.env && docker-compose up --build`

### Mac & Windows

Mac and Windows users should have no issues running just
`docker-compose up --build` or `docker-compose build` due to how those OS's run Docker.

```bash
docker-compose up --build

# OR

docker-compose build
docker-compose up
```

### Viewing the website

After running `docker-compose up --build` or `docker-compose up` you
should see the site up and running on `localhost:4000`

## Building a site

To build a bridgetown site run the following command:

```bash
docker-compose run --rm web yarn deploy
```

And this will place all your files into the `output` folder which can
then be used to host your site.

## Testing the "apply" command

Right now there is one big integration test which simply
checks that the files were created for Docker in a new bridgetown project.

In order for the tests to pass, you must first push the branch you're working on and then
wait for Github to update the raw file so the remote automation test will pass

```bash
git clone
https://github.com/ParamagicDev/bridgetown-automation-docker-compose/
cd bridgetown-automation-capybara
bundle install
bundle exec rake test
```

### Testing with Docker

```bash
git clone
https://github.com/ParamagicDev/bridgetown-automation-docker-compose
cd bridgetown-automation-docker-compose
docker-compose up --build
```

## Issues

If you have a `ruby-version` specified in your repo, make sure it aligns
with the Ruby version pulled down by Docker. Check out
[https://hub.docker.com/\_/ruby](https://hub.docker.com/_/ruby) for a
list of officially supported ruby versions.

Sometimes you may run into an issue with the binding of `node-sass`. To
fix the issue simply run:

```bash
docker-compose run --rm web npm reinstall node-sass
```
