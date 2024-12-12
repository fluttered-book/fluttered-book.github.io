---
title: Architecture
description: >-
  A small study of architecture for apps
weight: 1
---

# Architecture

## The apps we build

Let's start by examining the architecture of the apps we build so far.

### Photos

[Link](/docs/interactivity/photos)

It got a presentation layer.
That's it.
The app is all widgets.

![Architecture of Photos app](../images/architecture_photos.drawio.svg)

### Jokes

[Link](/docs/connecting-to-apis/jokes)

We have a presentation layer with `MyApp` and `JokePage`.

Then we have a data layer.
Consisting of `DataSource` and `JokeDto`.

![Architecture of Jokes app](../images/architecture_jokes.drawio.svg)

### Weather app

[Link](/docs/connecting-to-apis/weather1)

It follows a similar architecture, but slightly more complex.

![Architecture of Weather app](../images/architecture_weather.drawio.svg)

There are a lot more classes so I'm not going to name them all.

### Password manager

[Link](/docs/advanced-state-management/password-manager)

Where the two previous apps where basically just consuming data from a web API.
The password manager app is a bit different.

Its all local.
Not talking to any web API.
Its goal is to manage credentials and store them in a protected way.
For that it needs more logic than the previous examples.

![Architecture of Password Manager app](../images/architecture_password_manager.drawio.svg)

It got a different architecture because what is does is a lot different.
If there were one size fits all architecture we wouldn't be talking about it.

## Recommendation

For slightly bigger projects like your exam project.
You will (likely) both fetch data from an API and have logic within your app.
Which means that you will likely end up with the following layers.

![Architecture recommendation](../images/architecture_recommendation1.drawio.svg)

Bigger apps will have many features.
A feature in this context means a piece of functionality that is somewhat
self-contained.

Let's taka a shopping app as example.
It can have the following features:

- Storefront
- Product details
- Login
- Registration
- Shopping cart
- Checkout
- ...

Each feature will have its own screen, state & cubit.
Then it becomes a really good idea to group the presentation and logic by that
feature.
Simply put everything belonging to a feature in the same sub-folder.

[Read more](folder-structure)

![Architecture recommendation](../images/architecture_recommendation2.drawio.svg)

Data access layer can be shared between features or it can be feature specific
depending on your app.
