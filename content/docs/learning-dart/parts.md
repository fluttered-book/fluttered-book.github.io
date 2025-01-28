---
title: "Challenge: Computer parts"
weight: 8
---

## Challenge: Computer parts

Imagine you are making an app for a client.
The client is a local computer store and PC repair business.
They figured that they could cut costs if they had app to help them when building custom PCs.
An app that can help them keep track of the parts in a build and tell them how
the parts fit together.

Come up with a class hierarchy for assembling computer parts.

Such that:

1. The configurations you can make actually makes sense.
2. It is easy to understand the configuration.

Here is a crude example with cars:

```dart
class Car {
  String model;
  int wheels;
  int doors;
  Engine engine;

  Car(this.model, {required this.doors, this.wheels = 4, required this.engine});
}

class Engine {}
class V6 extends Engine {}
class V8 extends Engine {}

void main() {
  Car("Golf", doors: 4, engine: V6());
}
```

Here are some pointers to get you started, if you haven't built a computer
before.

Motherboard is what all other components are connected to.
It got:

- [CPU socket](https://en.wikipedia.org/wiki/CPU_socket)
  - CPU
    - Brand (Intel, AMD)
    - Number of cores
    - Model
- [DIMM](https://en.wikipedia.org/wiki/DIMM) slots for RAM
  - Type (DDR3, DDR4, DDR5)
  - Clock frequency
  - Capacity
- [PCIe](https://en.wikipedia.org/wiki/PCI_Express) for expansion cards
  - Graphics card
    - Brand (Nvidia, AMD, Intel)
    - Model
    - Memory
    - Cores
  - Network (Wi-Fi, ethernet)
- [M.2](https://en.wikipedia.org/wiki/M.2) for SSD
- [SATA](https://en.wikipedia.org/wiki/SATA) for HDD, SSD and optical drives
- [PSU](<https://en.wikipedia.org/wiki/Power_supply_unit_(computer)>) for power

Not need to support old legacy configurations since customers won't be buying
them anyway.

Write your code on [DartPad](https://dartpad.dev/) or in [Android Studio](../../install/android-studio).

{{% hint info %}}
You can create a Dart project by typing:

<pre>dart create yourprojectname</pre>

Then open the folder in Android Studio.

{{% /hint %}}
