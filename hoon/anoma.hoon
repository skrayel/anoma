::  Simple demo Nock standard library.
!.
=~  %909
~%  %k.909  ~  ~
::  layer 0: version stub (+3)
|%
++  anoma  +
--
::  layer 1: basic arithmetic (+1)
~%  %one  +  ~
|%
++  dec  ::  +342
  ~/  %dec
  |=  a=@
  ?<  =(0 a)
  =|  b=@
  |-  ^-  @
  ?:  =(a +(b))  b
  $(b +(b))
++  add  ::  +20
  ~/  %add
  |=  [a=@ b=@]
  ^-  @
  ?:  =(0 a)  b
  $(a (dec a), b +(b))
++  sub  ::  +47
  ~/  %sub
  |=  [a=@ b=@]
  ^-  @
  ?:  =(0 b)  a
  $(a (dec a), b (dec b))
++  lth  ::  +343
  ~/  %lth
  |=  [a=@ b=@]
  ^-  ?
  ?&  !=(a b)
      |-
      ?|  =(0 a)
          ?&  !=(0 b)
              $(a (dec a), b (dec b))
  ==  ==  ==
++  lte  ::  +84
  ~/  %lte
  |=  [a=@ b=@]
  ^-  ?
  |(=(a b) (lth a b))
++  gth  ::  +43
  ~/  %gth
  |=  [a=@ b=@]
  ^-  ?
  !(lte a b)
++  gte  ::  +22
  ~/  %gte
  |=  [a=@ b=@]
  ^-  ?
  !(lth a b)
++  mul  ::  +4
  ~/  %mul
  |:  [a=`@`1 b=`@`1]
  =|  c=@
  |-  ^-  @
  ?:  =(0 a)  c
  $(a (dec a), c (add b c))
++  div  ::  +170
  ~/  %div
  |:  [a=`@`1 b=`@`1]
  ?<  =(0 b)
  =|  c=@
  |-  ^-  @
  ?:  (lth a b)  c
  $(a (sub a b), c +(c))
++  mod  ::  +46
  ~/  %mod
  |:  [a=`@`1 b=`@`1]
  ^-  @
  ?<  =(0 b)
  (sub a (mul b (div a b)))
--
::  layer 2: data structures, HOFs
~%  %two  +  ~
|%
::  some types
+$  mold
  $~(* $-(* *))
+$  gate
  $-(* *)
++  trap
  |$  [product]
  _|?($:product)
++  unit
  |$  [item]
  $@(~ [~ u=item])
++  each
  |$  [left right]
  $%  [%| p=left]
      [%& p=right]
  ==
++  list
  |$  [item]
  $@(~ [i=item t=(list item)])
++  nonempty-list
  |$  [item]
  [i=item t=(list item)]
++  tree
  |$  [node]
  $@(~ [n=node l=(tree node) r=(tree node)])
::  utilities on some of these types
++  length
  |*  l=(list)
  ?~  l
    0
  +($(l t.l))
::  HOFs on some of these types
++  curry
  |*  [a=$-(^ *) b=*]
  =+  c=+<+.a
  |@
  ++  $
    (a b c)
  --
++  turn  ::  map over list
  |*  [a=(list) b=gate]
  ^-  (list _?>(?=(^ a) (b i.a)))
  |-
  ?~  a  ~
  [i=(b i.a) t=$(a t.a)]
++  foldr
  |*  [a=(list) b=_=>(~ |=([* *] +<+))]
  |-  ^+  ,.+<+.b
  ?~  a
    +<+.b
  (b i.a $(a t.a))
--
::  layer 3: fancy arithmetic
~%  %three  +  ~
|%
++  pow
  ~/  %pow
  |=  [a=@ b=@]
  ^-  @
  ?:  =(0 b)
    1
  (mul a $(b (dec b)))
++  modulo  ::  name this 'mod' and rename 'mod' to 'rem'?
  |_  modulus=@
  ++  reduce
    |=  a=@
    ^-  @
    (mod a modulus)
  ++  congruent
    |=  [a=@ b=@]
    =((reduce a) (reduce b))
  ++  add
    |=  [a=@ b=@]
    ^-  @
    (reduce (^add a b))
  ++  sub
    |=  [a=@ b=@]
    ^-  @
    (reduce (^sub (^add modulus a) (reduce b)))
  ++  mul
    |:  [a=`@`1 b=`@`1]
    ^-  @
    (reduce (^mul a b))
  ++  pow
    |=  [a=@ b=@]
    ^-  @
    (reduce (^pow a b))
  ++  neg
    |=  a=@
    ^-  @
    (^sub modulus (reduce a))
  ++  inv  ::  only works in prime fields
    |=  a=@
    ^-  @
    !!
  ++  div  ::  only works in prime fields
    |:  [a=`@`1 b=`@`1]
    ^-  @
    (mul a (inv b))
  --
--
::  layer 4: bits and bytes
~%  %four  +  ~
|%
++  bex  ::  2^a
  |=  a=@
  ^-  @
  ?:  =(0 a)  1
  (mul 2 $(a (dec a)))
++  block  ::  better name?
  |_  block-size=@  ::  exponent of 2, i.e. size 3 = 8 bits
  ++  bits
    (bex block-size)
  ++  modulus
    (bex (bex block-size))
  ++  lsh
    |=  [count=@ value=@]
    ^-  @
    ::  lsh(n, a) = a * 2^(bits to shift)
    (mul value (bex (mul bits count)))
  ++  rsh
    |=  [count=@ value=@]
    ^-  @
    ::  rsh(n, a) = a / 2^(bits to shift)
    (div value (bex (mul bits count)))
  ++  end  ::  least significant blocks
    |=  [count=@ value=@]
    ^-  @
    (mod value (bex (mul bits count)))
  ++  cut  ::  slice an array
    |=  [[offset=@ length=@] value=@]
    ^-  @
    (end length (rsh offset value))
  ++  cat  ::  lengthless concatenate, lsb-first
    |=  [fst=@ snd=@]
    ^-  @
    (add (lsh (met fst) snd) fst)
  ++  fil  ::  fill with repeating
    |=  [count=@ value=@]
    ^-  @
    =|  n=@
    =.  value  (reduce value)
    =/  result  value
    |-
    ?:  =(n count)
      (rsh 1 result)
    $(result (add value (lsh 1 result)), n +(n))
  ++  reduce  ::  shortcut to reduce modulo block
    |=  a=@
    ^-  @
    (end 1 a)
  ++  met  ::  measure in current block size
    |=  a=@
    ^-  @
    =|  result=@
    |-
    ?:  =(0 a)  result
    $(a (rsh 1 a), result +(result))
  ++  inv  ::  invert all bits mod block size
    |=  a=@
    ^-  @
    (sub (dec modulus) (reduce a))
  ++  w-add  ::  wrapping addition mod block size
    |=  [a=@ b=@]
    ^-  @
    (reduce (add a b))
  ++  twos-complement  ::  two's complement mod block size
    |=  a=@
    ^-  @
    (w-add (inv a) 1)
  --
++  xeb  ::  log_2(a) + 1
  ::  NB: not an inverse to bex
  ::  this is "number of bits required"
  |=  a=@
  ^-  @
  (~(met block 0) a)
--
::  layer 5: under construction (axes may change)
~%  %four  +  ~
|%
::  bitwise xor
++  mix                                                 ::  binary xor
  ~/  %mix
  |=  [a=@ b=@]
  ^-  @
  =+  [c=0 d=0]
  |-
  ?:  ?&(=(0 a) =(0 b))  d
  %=  $
    a   (~(rsh block 0) 1 a)
    b   (~(rsh block 0) 1 b)
    c   +(c)
    d   (add d (~(lsh block 0) c =((~(end block 0) 1 a) (~(end block 0) 1 b))))
  ==
++  pair
  |$  [head tail]
  [p=head q=tail]
++  tree
  |$  [node]
  $@(~ [n=node l=(tree node) r=(tree node)])
++  map
  |$  [key value]
  (tree (pair key value))
++  mat                                                 ::  length-encode
  ~/  %mat
  |=  a=@
  ^-  [p=@ q=@]
  ?:  =(0 a)
    [1 1]
  =+  b=(~(met block 0) a)
  =+  c=(~(met block 0) b)
  :-  (add (add c c) b)
  (~(cat block 0) (bex c) (mix (~(end block 0) (dec c) b) (~(lsh block 0) (dec c) a)))
::
++  rub                                                 ::  length-decode
  ~/  %rub
  |=  [a=@ b=@]
  ^-  [p=@ q=@]
  =+  ^=  c
      =+  [c=0 m=(~(met block 0) b)]
      |-  ?<  (gth c m)
      ?.  =(0 (~(cut block 0) [(add a c) 1] b))
        c
      $(c +(c))
  ?:  =(0 c)
    [1 0]
  =+  d=(add a +(c))
  =+  e=(add (bex (dec c)) (~(cut block 0) [d (dec c)] b))
  [(add (add c c) e) (~(cut block 0) [(add d (dec c)) e] b)]
++  jam
  ~/  %jam
  |=  a=*
  ^-  @
  =+  b=0
  =<  q
  |-  ^-  [p=@ q=@]
  ?:  ?=(@ a)
    =+  d=(mat a)
    [(add 1 p.d) (~(lsh block 0) 1 q.d)]
  =>  .(b (add 2 b))
  =+  d=$(a -.a)
  =+  e=$(a +.a, b (add b p.d))
  [(add 2 (add p.d p.e)) (mix 1 (~(lsh block 0) 2 (~(cat block 0) q.d q.e)))]
++  cue
  ~/  %cue
  |=  a=@
  ^-  *
  =+  b=0
  =<  q
  |-  ^-  [p=@ q=*]
  ?:  =(0 (~(cut block 0) [b 1] a))
    =+  c=(rub +(b) a)
    [+(p.c) q.c]
  =+  c=(add 2 b)
  ?>  =(0 (~(cut block 0) [+(b) 1] a))
  =+  u=$(b c)
  =+  v=$(b (add p.u c))
  =+  w=[q.u q.v]
  [(add 2 (add p.u p.v)) w]
--
::  layer 6: cryptographic code
~%  %six  +  ~
|%
++  sign  ::  +10 Please fill out
  ~/  %sign
  |=  [a=@ b=@]
  =+  c=%sign
  ^-  @
  !!
++  verify  ::  +4 Please fill out
  ~/  %verify
  |=  [a=@ b=@]
  =+  c=%verify
  ^-  ?(~ [~ @])
  !!
++  sign-detatched  ::  +23 Please fill out
  ~/  %sign-detatched
  |=  [a=@ b=@]
  =+  c=%sign-detatched
  ^-  @
  !!
++  verify-detatched  ::  +22 Please fill out
  ~/  %verify-detatched
  |=  [a=@ b=@ c=@]
  =+  d=%verify-detatched
  ^-  @
  !!
--
::  layer 7: SHA and random bit generation
~%  %seven  +  ~
|%
++  shim  :: A shim for layer 7
  |%
  ++  bloq  @
  ++  step
    _`@u`1
  +$  bite  $@(bloq [=bloq =step])
  ++  met  :: a shim over met
    |=  [a=@ b=@]
    ^-  @
    (~(met block a) b)
  ++  cut  ::  a shim over cut
    ~/  %cut
    |=  [a=@ [b=step c=step] d=@]
    (~(end block a) c (~(rsh block a) b d)) :: (end [a c] (rsh [a b] d))
  ++  end  ::  a shim over end
    ~/  %end
    |=  [a=bite b=@]
    =/  [=bloq =step]  ?^(a a [a *step])
    (~(end block bloq) step b)  ::  (mod b (bex (mul (bex bloq) step)))
  ++  rsh  ::  a shim over rsh
    ~/  %rsh
    |=  [a=bite b=@]
    =/  [=bloq =step]  ?^(a a [a *step])
    (~(rsh block bloq) step b)  ::  (div b (bex (mul (bex bloq) step)))
  ++  lsh :: a shim over lsh
    ~/  %lsh
    |=  [a=bite b=@]
    =/  [=bloq =step]  ?^(a a [a *step])
    (~(lsh block bloq) step b)  ::  (mul b (bex (mul (bex bloq) step)))
  ++  con
    ~/  %con
    |=  [a=@ b=@]
    =+  [c=0 d=0]
    |-  ^-  @
    ?:  ?&(=(0 a) =(0 b))  d
    %=  $
      a   (rsh 0 a)
      b   (rsh 0 b)
      c   +(c)
      d   %+  add  d
            %+  lsh  [0 c]
            ?&  =(0 (end 0 a))
                =(0 (end 0 b))
            ==
    ==
  ++  can
    ~/  %can
    |=  [a=bloq b=(list [p=step q=@])]
    ^-  @
    ?~  b  0
    (add (end [a p.i.b] q.i.b) (lsh [a p.i.b] $(b t.b)))
  ++  run
    ~/  %run
    |=  [a=bite b=@ c=$-(@ @)]
    (rep a (turn (rip a b) c))
  ++  rep
    ~/  %rep
    |=  [a=bite b=(list @)]
    =/  [=bloq =step]  ?^(a a [a *step])
    =|  i=@ud
    |-  ^-  @
    ?~  b   0
    %+  add  $(i +(i), b t.b)
    (lsh [bloq (mul step i)] (end [bloq step] i.b))
  ++  rip
    ~/  %rip
    |=  [a=bite b=@]
    ^-  (list @)
    ?:  =(0 b)  ~
    [(end a b) $(b (rsh a b))]
  ++  dis
    ~/  %dis
    |=  [a=@ b=@]
    =|  [c=@ d=@]
    |-  ^-  @
    ?:  ?|(=(0 a) =(0 b))  d
    %=  $
      a   (rsh 0 a)
      b   (rsh 0 b)
      c   +(c)
      d   %+  add  d
            %+  lsh  [0 c]
            ?|  =(0 (end 0 a))
                =(0 (end 0 b))
            ==
    ==
  ++  fe
    |_  a=bloq
    ++  sum  |=([b=@ c=@] (sit (add b c)))
    ++  sit  |=(b=@ (end a b))
    ++  ror  |=  [b=bloq c=@ d=@]  ^-  @
             =+  e=(sit d)
             =+  f=(bex (sub a b))
             =+  g=(mod c f)
             (sit (con (rsh [b g] e) (lsh [b (sub f g)] e)))
    ++  net  |=  b=@  ^-  @
             =>  .(b (sit b))
             ?:  (lte a 3)
               b
             =+  c=(dec a)
             %+  con
               (lsh c $(a c, b (cut c [0 1] b)))
             $(a c, b (cut c [1 1] b))
    ++  inv  |=(b=@ (sub (dec out) (sit b)))
    ++  out  (bex (bex a))
    --
  --
++  shay  ::  SHA-256 with length
  ~/  %shay
  |=  [len=@u ruz=@]  ^-  @
  =,  shim
  =>  .(ruz (cut 3 [0 len] ruz))
  =+  [few==>(fe .(a 5)) wac=|=([a=@ b=@] (cut 5 [a 1] b))]
  =+  [sum=sum.few ror=ror.few net=net.few inv=inv.few]
  =+  ral=(lsh [0 3] len)
  =+  ^=  ful
      %+  can  0
      :~  [ral ruz]
          [8 128]
          [(mod (sub 960 (mod (add 8 ral) 512)) 512) 0]
          [64 (~(net fe 6) ral)]
      ==
  =+  lex=(met 9 ful)
  =+  ^=  kbx  0xc671.78f2.bef9.a3f7.a450.6ceb.90be.fffa.
                 8cc7.0208.84c8.7814.78a5.636f.748f.82ee.
                 682e.6ff3.5b9c.ca4f.4ed8.aa4a.391c.0cb3.
                 34b0.bcb5.2748.774c.1e37.6c08.19a4.c116.
                 106a.a070.f40e.3585.d699.0624.d192.e819.
                 c76c.51a3.c24b.8b70.a81a.664b.a2bf.e8a1.
                 9272.2c85.81c2.c92e.766a.0abb.650a.7354.
                 5338.0d13.4d2c.6dfc.2e1b.2138.27b7.0a85.
                 1429.2967.06ca.6351.d5a7.9147.c6e0.0bf3.
                 bf59.7fc7.b003.27c8.a831.c66d.983e.5152.
                 76f9.88da.5cb0.a9dc.4a74.84aa.2de9.2c6f.
                 240c.a1cc.0fc1.9dc6.efbe.4786.e49b.69c1.
                 c19b.f174.9bdc.06a7.80de.b1fe.72be.5d74.
                 550c.7dc3.2431.85be.1283.5b01.d807.aa98.
                 ab1c.5ed5.923f.82a4.59f1.11f1.3956.c25b.
                 e9b5.dba5.b5c0.fbcf.7137.4491.428a.2f98
  =+  ^=  hax  0x5be0.cd19.1f83.d9ab.9b05.688c.510e.527f.
                 a54f.f53a.3c6e.f372.bb67.ae85.6a09.e667
  =+  i=0
  |-  ^-  @
  ?:  =(i lex)
    (run 5 hax net)
  =+  ^=  wox
      =+  dux=(cut 9 [i 1] ful)
      =+  wox=(run 5 dux net)
      =+  j=16
      |-  ^-  @
      ?:  =(64 j)
        wox
      =+  :*  l=(wac (sub j 15) wox)
              m=(wac (sub j 2) wox)
              n=(wac (sub j 16) wox)
              o=(wac (sub j 7) wox)
          ==
      =+  x=:(mix (ror 0 7 l) (ror 0 18 l) (rsh [0 3] l))
      =+  y=:(mix (ror 0 17 m) (ror 0 19 m) (rsh [0 10] m))
      =+  z=:(sum n x o y)
      $(wox (con (lsh [5 j] z) wox), j +(j))
  =+  j=0
  =+  :*  a=(wac 0 hax)
          b=(wac 1 hax)
          c=(wac 2 hax)
          d=(wac 3 hax)
          e=(wac 4 hax)
          f=(wac 5 hax)
          g=(wac 6 hax)
          h=(wac 7 hax)
      ==
  |-  ^-  @
  ?:  =(64 j)
    %=  ^$
      i  +(i)
      hax  %+  rep  5
           :~  (sum a (wac 0 hax))
               (sum b (wac 1 hax))
               (sum c (wac 2 hax))
               (sum d (wac 3 hax))
               (sum e (wac 4 hax))
               (sum f (wac 5 hax))
               (sum g (wac 6 hax))
               (sum h (wac 7 hax))
           ==
    ==
  =+  l=:(mix (ror 0 2 a) (ror 0 13 a) (ror 0 22 a))    ::  s0
  =+  m=:(mix (dis a b) (dis a c) (dis b c))            ::  maj
  =+  n=(sum l m)                                       ::  t2
  =+  o=:(mix (ror 0 6 e) (ror 0 11 e) (ror 0 25 e))    ::  s1
  =+  p=(mix (dis e f) (dis (inv e) g))                 ::  ch
  =+  q=:(sum h o p (wac j kbx) (wac j wox))            ::  t1
  $(j +(j), a (sum q n), b a, c b, d c, e (sum d q), f e, g f, h g)
++  shax  ::  SHA-256
  ~/  %shax
  |=  ruz=@  ^-  @
  =,  shim
  (shay [(met 3 ruz) ruz])
++  shas  ::  Salted hash using SHA-256 plus salt
  ~/  %shas
  |=  [sal=@ ruz=@]
  (shax (mix sal (shax ruz)))
++  og
  ~/  %og
  ^|  |_  a=@
  ++  split
    ^-  [_og _og]
    [.(a (shas %split-l a)) .(a (shas %split-r a))]
  ++  raw  :: Random bit generation
    ~/  %raw
    |=  b=@  ^-  @
    =,  shim
    %+  can
      0
    =+  c=(shas %og-a (mix b a))
    |-  ^-  (list [@ @])
    ?:  =(0 b)
      ~
    =+  d=(shas %og-b (mix b (mix a c)))
    ?:  (lth b 256)
      [[b (end [0 b] d)] ~]
    [[256 d] $(c d, b (sub b 256))]
  ++  rad  :: Random number generation in range
    |=  b=@  ^-  @
    =,  shim
    ~_  leaf+"rad-zero"
    ?<  =(0 b)
    =+  c=(raw (met 0 b))
    ?:((lth c b) c $(a +(a)))
  ++  raws  ::  Random bit generation with continuation
    |=  b=@
    =+  r=(raw b)
    [r +>.$(a (shas %og-s (mix a r)))]
  ++  rads  :: Random number generation in range with continuation
    |=  b=@
    =+  r=(rad b)
    [r +>.$(a (shas %og-s (mix a r)))]
  --
--
::  layer 8: signed arithmetic
::  uses `end` and `rsh` from layer 7 shim
~%  %eight  +  ~
|%
++  abs  ::  Absolute value
  ~/  %abs
  =,  shim
  |=(a=@s (add (end 0 a) (rsh 0 a)))
++  dif  ::  Subtraction
  ~/  %dif
  |=  [a=@s b=@s]
  (sum a (new !(syn b) (abs b)))
++  dul  ::  Modulus
  ~/  %dul
  |=  [a=@s b=@]
  =+(c=(old a) ?:(-.c (mod +.c b) (sub b +.c)))
++  fra  ::  Divide
  ~/  %fra
  |=  [a=@s b=@s]
  (new =(0 (mix (syn a) (syn b))) (div (abs a) (abs b)))
++  new  ::  Atom to @s
  ~/  %new
  |=  [a=? b=@]
  `@s`?:(a (mul 2 b) ?:(=(0 b) 0 +((mul 2 (dec b)))))
++  old  ::  Sign and absolute value
  ~/  %old
  |=(a=@s [(syn a) (abs a)])
++  pro  ::  Multiplication
  ~/  %pro
  |=  [a=@s b=@s]
  (new =(0 (mix (syn a) (syn b))) (mul (abs a) (abs b)))
++  rem  ::  Remainder
  ~/  %rem
  |=([a=@s b=@s] (dif a (pro b (fra a b))))
++  sum  ::  Addition
  ~/  %sum
  |=  [a=@s b=@s]
  =+  [c=(old a) d=(old b)]
  ?:  -.c
    ?:  -.d
      (new & (add +.c +.d))
    ?:  (gte +.c +.d)
      (new & (sub +.c +.d))
    (new | (sub +.d +.c))
  ?:  -.d
    ?:  (gte +.c +.d)
      (new | (sub +.c +.d))
    (new & (sub +.d +.c))
  (new | (add +.c +.d))
++  sun  ::  @u to @s
  ~/  %sun
  |=(a=@u (mul 2 a))
++  syn  ::  Sign test
  ~/  %syn
  =,  shim
  |=(a=@s =(0 (end 0 a)))
++  cmp  ::  Compare
  ~/  %cmp
  |=  [a=@s b=@s]
  ^-  @s
  ?:  =(a b)
    --0
  ?:  (syn a)
    ?:  (syn b)
      ?:  (gth a b)
        --1
      -1
    --1
  ?:  (syn b)
    -1
  ?:  (gth a b)
    -1
  --1
--
==
