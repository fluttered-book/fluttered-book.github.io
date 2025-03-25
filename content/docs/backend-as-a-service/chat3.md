---
title: Chat - Authorization
description: Chat 3 - Authorization
weight: 5
---

{{% hint warning %}}
Work-in-progress
{{% /hint %}}

# Chat - Authorization

{{% hint info %}}
This guide is based on [Flutter Authorization with
RLS](https://supabase.com/blog/flutter-authorization-with-rls).
I'm making my own version to better fit the narrative I want to convey in this
book.
{{% /hint %}}

## Introduction

Currently, the chat is open for everyone.
If you put an app like this on the app store, and people start using it.
Within long the chat would be flooded with horrible things.
You know like scammers, drug dealers, bots and people posting what they had for
lunch.

What the app needs is private chat rooms.
Such that people can discuss meaningful topic in peace.
All the important stuff in life.
Like how to defeat Gwyn, Lord of Cinder etc.

We create [Row Level
Security (RLS)](https://supabase.com/docs/guides/database/postgres/row-level-security)
policies to enforce that rooms are kept private.
RLS allows you to make access rules directly in the database.

Silly full-stack developers, spending so much time writing back-ends.
All they need is Postgres (and Supabase).
If you think about it, most back-ends are just fancy wrappers around a
database.
And Supabase is a featureful generic wrapper, so it can be used for many
different kinds of projects.
🤯

_♫ I'm all about the BaaS, no back-end ♫_
