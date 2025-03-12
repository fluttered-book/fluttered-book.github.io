---
title: Mock API
weight: 13
---

# Mock API

Sometimes you just need to prototype an app idea without wasting time on making
back-end for it.
If all you need is some CRUD endpoints with some fake data test against, then
stay tuned, as I got the solution.

[Mockoon](https://mockoon.com/) is a desktop app that allows you to create
quick mock APIs.

![Screenshot of the Mockoon desktop app](../images/mockoon.png)

Adding fake data and CRUD endpoints is just a couple of clicks. It uses
[Faker](https://fakerjs.dev/) to generate mock data.
Have a look at [Fake - API Overview](https://fakerjs.dev/api/) to see what kind
of data can be generated.

As a proof-of-concept I converted the [ToDo app](../../advanced-state-management/todo/) to make API calls and
provided a setup for Mockoon to test against.
Check out the "Example" link below.

## [Example](https://github.com/fluttered-book/todo/tree/mockoon)

{{% hint warning %}}
Make sure you are on "mockoon" branch.
{{% /hint %}}
