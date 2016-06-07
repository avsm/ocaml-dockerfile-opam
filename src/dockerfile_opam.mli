(*---------------------------------------------------------------------------
   Copyright (c) 2016 Anil Madhavapeddy. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

(** Rules for generating Dockerfiles involving OPAM *)

(** RPM distribution specific rules involving OPAM and OCaml *)
module RPM : sig

  val install_system_opam : [< `CentOS6 | `CentOS7 ] -> Dockerfile.t
  (** Install the system OPAM packages via Yum *)
end

(** Apt distribution specific rules involving OPAM and OCaml *)
module Apt : sig

  val install_system_opam : Dockerfile.t
  (** Install the system OPAM packages via [apt-get] *)
end

val run_as_opam : ('a, unit, string, Dockerfile.t) format4 -> 'a
(** [run_as_opam fmt] runs the command specified by the [fmt]
    format string as the [opam] user. *)

val opamhome : string
(** The location of the [opam] user home directory *)

val opam_init :
  ?repo:string -> ?compiler_version:string -> unit -> Dockerfile.t
(** [opam_init ?repo ?compiler_version] initialises the OPAM
    repository.  The [repo] is [git://github.com/ocaml/opam-repository]
    by default.  If [compiler-version] is specified, an [opam switch]
    is executed to that version.  If unspecified, then the [system]
    switch is default. *)

val install_opam_from_source : ?prefix:string -> ?branch:string -> unit -> Dockerfile.t
(** Commands to install OPAM via a source code checkout from GitHub.
    The [branch] defaults to the [1.2] stable branch.
    The binaries are installed under [<prefix>/bin], defaulting to [/usr/local/bin]. *)

val install_cloud_solver : Dockerfile.t
(** [install_cloud_solver] will use the hosted OPAM aspcud service from IRILL.  It will
    install a fake [/usr/bin/aspcud] script that requires online connectivity. *)

val header: ?maintainer:string -> string -> string -> Dockerfile.t
(** [header image tag] initalises a fresh Dockerfile using the [image:tag]
    as its base. *)

(*---------------------------------------------------------------------------
   Copyright (c) 2016 Anil Madhavapeddy

   Permission to use, copy, modify, and/or distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
   WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
   MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
   ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
   ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
   OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  ---------------------------------------------------------------------------*)

