*Five of a kind, where all five cards have the same label: AAAAA*

```yaml
JJJJJ -> FiveOfAKind

aJJJJ -> FiveOfAKind
aaJJJ -> FiveOfAKind
aaaJJ -> FiveOfAKind
aaaaJ -> FiveOfAKind
aaaaa -> FiveOfAKind
```
> i.e. 1 of a non-joker, remaining are jokers => FiveOfAKind

---

*Four of a kind, where four cards have the same label and one card has a different label: AA8AA*

```yaml
abJJJ -> FourOfAKind
aabJJ -> FourOfAKind
aaabJ -> FourOfAKind
aaaab -> FourOfAKind
```

> i.e. 1 of type "a", at least 1 of type "b", and remaining are jokers => FourOfAKind
> 2 size1, remaining jokers

---

*Full house, where three cards have the same label, and the remaining two cards share a different label: 23332*

```yaml
~~aaaJJ => FullHouse (with jack being "a"*2) — 1 size3 2 free~~
~~aaabJ => FullHouse (with jack being "b") - 1 size3, 1 size1, 1free~~
aabbJ => FullHouse (with jack being "a") — 2 size2, 1 free

~~aabJJ => FullHouse (with jack being "a" and "b") — 1 size2, 1 size1, 2 free~~
~~aaJJJ~~
```

---

*Three of a kind, where three cards have the same label, and the remaining two cards are each different*
*from any other card in the hand: TTT98*

```yaml
~~aaabJ (with J being "c") - 1 size3, 1 size1, 1 free~~
aabcJ (with J being "a")

```



---

Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432

abcJJ => TwoPair (with J being "a" and "b")

---

One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4

---

High card, where all cards' labels are distinct: 23456
