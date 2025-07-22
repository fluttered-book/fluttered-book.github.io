---
title: Chat - Challenges
description: >-
  Expand the chat app with cool new features
weight: 5
---

# Chat - Challenges

## Profile

Add functionality, so a user can update their profile.

You can find hints in [Build a User Management App with
Flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
tutorial.

See also [Bonus: Profile photos](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter?platform=web#bonus-profile-photos)

## Photo chat

> One Picture is Worth a Thousand Words

Convert the app so you can chat by sending photos.
Similar to the ghost-icon app.

See [Storage
Quickstart](https://supabase.com/docs/guides/storage/quickstart?language=dart)
before you proceed.

1. Add a "type" field to messages table that can have values "text", "photo".
   - Use Supabase built-in AI to help you generate SQL to change the schema.
2. Take pictures with [camera plugin](https://pub.dev/packages/camera) like you did in the [photos app](../interactivity/photos).
3. [Upload images to a storage bucket](https://supabase.com/docs/reference/dart/storage-from-upload).
4. Change `ChatCubit.sendMessage` to save message with "type" field set to
   "photo" and "content" field set to the file path for uploaded photo.

Also, see [Storage Access
Control](https://supabase.com/docs/guides/storage/security/access-control)

## Presence

Indicate which users are currently online using the [Presence
feature](https://supabase.com/docs/guides/realtime/presence?language=dart) of
Supabase.

## And Now for Something Completely Different

Are you bored?
Do you want to play games on your phone instead?

Follow [How to build a real-time multiplayer game with Flutter
Flame](https://supabase.com/blog/flutter-real-time-multiplayer-game).

Assets are found
[here](https://github.com/supabase/supabase/tree/master/examples/realtime/flutter-multiplayer-shooting-game/assets/images).

Remove `response == ChannelResponse.rateLimited &&` from the while loop in
`_GamePageState`.
