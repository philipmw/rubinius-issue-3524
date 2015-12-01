This is a bug report against Rubinius 2.5.8.

# Symptom

A marshalled custom object fails to unmarshal on Rubinius 2.5.8, but it works on JRuby and MRI Ruby.

# Details

Included is a minimal test case.  A _Promise_ object wraps an _InnerClass_ object and delegates all unrecognized method calls to it.  _Promise_ inherits from _BasicObject_, so it's effectively a transparent wrapper around _InnerClass_.

When marshaling on Rubinius, the _Promise_ object is called with `#__class__`.  By default, this method is delegated to _InnerClass_ like all others.  As a result, the marshal string looks like `InnerClass > InnerClass`, which fails when unmarshaling.

In contrast, in Rubies, the _Promise_ object knows its class name, so the marshal string looks like `Promise > InnerClass` and correctly unmarshals.

````
% rbenv local 2.2.3
0c4de9cd2926% bundle exec ruby test.rb
Run options: --seed 56865

# Running:

.

Finished in 0.001321s, 756.7811 runs/s, 756.7811 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
0c4de9cd2926% rbenv local jruby-1.7.19
0c4de9cd2926% bundle exec ruby test.rb
Run options: --seed 57593

# Running:

.

Finished in 0.013000s, 76.9231 runs/s, 76.9231 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
0c4de9cd2926% rbenv local rbx-2.5.8
0c4de9cd2926% bundle exec ruby test.rb
Run options: --seed 55453

# Running:

E

Finished in 0.007167s, 139.5284 runs/s, 0.0000 assertions/s.

  1) Error:
TestPromise#test_marshal:
NoMethodError: undefined method `_load' on InnerClass (Class)
    kernel/delta/kernel.rb:78:in `_load (method_missing)'
    kernel/common/marshal.rb:833:in `construct_user_defined'
    kernel/common/marshal.rb:521:in `construct'
    kernel/common/marshal.rb:159:in `set_instance_variables'
    kernel/common/integer.rb:196:in `times'
    kernel/common/marshal.rb:157:in `set_instance_variables'
    kernel/common/marshal.rb:766:in `construct_object'
    kernel/common/marshal.rb:519:in `construct'
    kernel/common/marshal.rb:1214:in `load'
    test.rb:36:in `test_marshal'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
0c4de9cd2926% RUBINIUS_FIX=true bundle exec ruby test.rb
Run options: --seed 56613

# Running:

*** Promise#__class__ invoked!
.

Finished in 0.005071s, 197.1998 runs/s, 197.1998 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
````
