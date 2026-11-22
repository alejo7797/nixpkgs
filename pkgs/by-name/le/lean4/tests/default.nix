{
  lean4,
  runCommand,
}:

{
  smoke = runCommand "lean4-smoke-test" { nativeBuildInputs = [ lean4 ]; } ''
    lean --stdin <<EOF
    import Std
    example : 1 + 1 = 2 := by decide
    example : ∀ (x y : BitVec 8), x &&& y = y &&& x := by bv_decide
    EOF

    lake new hello
    lake -d hello --no-ansi exe hello

    touch $out
  '';
}
