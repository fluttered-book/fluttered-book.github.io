---
title: Acronym generator
weight: 5
---

{{< classic-dartpad >}}

# Acronym generator

Write an acronym generator.
You give it some text and it will abbreviate it to an acronym.

## Examples

| Text                               | Abbreviation |
| ---------------------------------- | ------------ | -------------------------------- |
| Joint Photographic Experts Group   | JPEG         |
| Secure by Design                   | SBD          | Abbreviates text with lower case |
| HyperText Transfer Protocol Secure | HTTPS        | Abbreviates text with mixed case |
| Last in. First out                 | LIFO         | Ignores punctuation              |
| You only live once 👶💣🪦          | YOLO         | Ignores emojis                   |

## Code

```run-dartpad:theme-dark:mode-dart:width-100%:height-460px
{% include exercise path="codelab/lib/acronym/" %}
```
