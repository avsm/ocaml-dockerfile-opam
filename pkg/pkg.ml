#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
open Topkg

let () =
  Pkg.describe "dockerfile-opam" @@ fun c ->
  Ok [ Pkg.mllib "src/dockerfile-opam.mllib" ]
