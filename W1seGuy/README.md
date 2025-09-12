# W1seGuy
## Difficulty: Medium

A w1se guy 0nce said, the answer is usually as plain as day.

Your friend told me you were wise, but I don't believe them. Can you prove me wrong?

When you are ready, click the Start Machine button to fire up the Virtual Machine. Please allow 3-5 minutes for the VM to start fully.

The server is listening on port 1337 via TCP. You can connect to it using Netcat or any other tool you prefer.

Answer the questions below

- What is the first flag?
- What is the second and final flag?


```bash
nc 10.201.92.164 1337

This XOR encoded text has flag 1: 047a0e211861532f341c154a371b1c240620310b115c3169093c7e3a323d22463a6a1d224a0c2815
```
Use CyberChef to find the first flag
+ From Hex
+ XOR
+ To Hex

`THM{p1alntExtAtt4ckcAnr3alLyhUrty0urxOr}`
```bash

What is the encryption key? P2CZh

Congrats! That is the correct key! Here is flag 2: THM{BrUt3_ForC1nG_XOR_cAn_B3_FuN_nO?}

```