(*---------------------------------------------------------------------------
   Copyright (c) 2016 Anil Madhavapeddy. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

(** Run OPAM commands across a matrix of Docker containers.
    Each of these containers represents a different version of
    OCaml, OPAM and an OS distribution (such as Debian or Alpine).
  *)

(** {2 Known distributions and OCaml variants} *)

type t = [ 
  | `Alpine of [ `V3_3 ]
  | `CentOS of [ `V6 | `V7 ]
  | `Debian of [ `V9 | `V8 | `V7 | `Stable | `Testing | `Unstable ]
  | `Raspbian of [ `V8 | `V7 ]
  | `Fedora of [ `V21 | `V22 | `V23 ]
  | `OracleLinux of [ `V7 ]
  | `Ubuntu of [ `V12_04 | `V14_04 | `V15_04 | `V15_10 | `V16_04 ]
] [@@deriving sexp] 
(** Supported Docker container distributions *)

val distros : t list
(** Enumeration of the supported Docker container distributions *)

val slow_distros : t list
(** Enumerations of slower non-x86 distributions like ARM Raspbian *)

val latest_stable_distros : t list
(** Enumeration of the latest stable (ideally LTS) supported distributions. *)

val master_distro : t
(** The distribution that is the top-level alias for the [latest] tag
    in the [ocaml/opam] Docker Hub build. *)

val ocaml_versions : Bytes.t list
(** Enumeration of supported OCaml compiler versions. *)

val latest_ocaml_version : Bytes.t
(** The latest stable OCaml release. *)

val opam_versions : Bytes.t list
(** Enumeration of supported OPAM package manager versions. *)

val builtin_ocaml_of_distro : t -> Bytes.t option
(** [builtin_ocaml_of_distro t] will return the OCaml version
  supplied with the distribution packaging, and [None] if there
  is no supported version. *)

val tag_of_distro : t -> Bytes.t
(** Convert a distribution to a Docker Hub tag.  The full
  form of this is [ocaml/TAG] on the Docker Hub. *)

val distro_of_tag : Bytes.t -> t option
(** [distro_of_tag s] parses [s] into a {!t} distribution, and
    [None] otherwise. *)

val opam_tag_of_distro : t -> Bytes.t -> Bytes.t
(** [opam_tag_of_distro distro ocaml_version] will generate
  a Docker Hub tag that maps to the container that matches
  the OS/OCaml combination.  They can be found by default in
  the [ocaml] organisation in Docker Hub. *)

val latest_tag_of_distro : t -> Bytes.t
(** [latest_tag_of_dsistro distro] will generate a Docker Hub
  tag that is a convenient short form for the latest stable
  release of a particular distribution.  This tag will be
  regularly rewritten to point to any new releases of the
  distribution. *)

val human_readable_string_of_distro : t -> Bytes.t
(** [human_readable_string_of_distro t] returns a human readable
  version of the distribution tag, including version information. *)

val human_readable_short_string_of_distro : t -> Bytes.t
(** [human_readable_short_string_of_distro t] returns a human readable
  short version of the distribution tag, excluding version information. *)

val compare : t -> t -> int
(** [compare a b] is a lexical comparison function for {!t}. *)

(** {2 Dockerfile generation} *)

val to_dockerfile :
  ?pin:Bytes.t ->
  ocaml_version:Bytes.t ->
  distro:t -> unit -> Dockerfile.t
(** [to_dockerfile ?pin ~ocaml_version ~distro] generates
   a Dockerfile for [distro], with OPAM installed and the
   current switch pointing to [ocaml_version]. If [pin]
   is specified then an [opam pin add <pin>] will be added
   to the initialisation. *)

val dockerfile_matrix :
  ?pin:Bytes.t -> unit -> (t * Bytes.t * Dockerfile.t) list
(** [dockerfile_matrix ?pin ()] contains the list of Docker tags
   and their associated Dockerfiles for all distributions.
   The user of the container can assume that OPAM is installed
   and initialised to the central remote, and that [opam depext]
   is available on that container. If [pin] is specified then an
   [opam pin add <pin>] will be added to the initialisation. *)

val latest_dockerfile_matrix :
  ?pin:Bytes.t -> unit -> (t * Dockerfile.t) list
(** [latest_dockerfile_matrix] contains the list of Docker tags
   and Dockerfiles for the latest releases of distributions.
   These contain the latest stable version of the distribution,
   the most recently released version of OCaml, and the freshest
   version of OPAM supported on that distribution.

   The user of the container can assume that OPAM is installed
   and initialised to the central remote, and that [opam depext]
   is available on that container. If [pin] is specified then an
   [opam pin add <pin>] will be added to the initialisation. *)

(** {2 Dockerfile generators and iterators } *)

val map :
  ?filter:(t * Bytes.t * Dockerfile.t -> bool)  ->
  ?org:Bytes.t ->
  (distro:t -> ocaml_version:Bytes.t -> Dockerfile.t -> 'a) ->
  'a list
(* [map ?org fn] will map all the supported Docker containers across [fn].
   [fn] will be passed the {!distro}, OCaml compiler version and a base
   Dockerfile that is based off a Docker Hub image from the [org] organisation
   (by default, this is [ocaml/opam]. *)

val map_tag :
  ?filter:(t * Bytes.t * Dockerfile.t -> bool) ->
  (distro:t -> ocaml_version:Bytes.t -> 'a) -> 'a list
(** [map_tag fn] executes [fn distro ocaml_version] with a tag suitable for use
   against the [ocaml/opam:TAG] Docker Hub. *)

val generate_dockerfile : ?crunch:bool -> string -> Dockerfile.t -> unit
(** [generate_dockerfile output_dir docker] will output Dockerfile inside
    the [output_dir] subdirectory.

    The [crunch] argument defaults to true and applies the {!Dockerfile.crunch}
    optimisation to reduce the number of layers; disable it if you really want
    more layers. *)

val generate_dockerfiles : ?crunch:bool -> string ->
  (Bytes.t * Dockerfile.t) list -> unit
(** [generate_dockerfiles output_dir (name * docker)] will
    output a list of Dockerfiles inside the [output_dir/] subdirectory,
    with each Dockerfile named as [Dockerfile.<release>].

    The [crunch] argument defaults to true and applies the {!Dockerfile.crunch}
    optimisation to reduce the number of layers; disable it if you really want
    more layers. *)

val generate_dockerfiles_in_directories : ?crunch:bool -> string ->
  (Bytes.t * Dockerfile.t) list -> unit
(** [generate_dockerfiles_in_directories output_dir (name * docker)] will
    output a list of Dockerfiles inside the [output_dir/name] subdirectory,
    with each directory containing the Dockerfile specified by [docker].

    The [crunch] argument defaults to true and applies the {!Dockerfile.crunch}
    optimisation to reduce the number of layers; disable it if you really want
    more layers. *)

val generate_dockerfiles_in_git_branches : ?readme:string -> ?crunch:bool ->
  string -> (Bytes.t * Dockerfile.t) list -> unit
(** [generate_dockerfiles_in_git_branches output_dir (name * docker)] will
    output a set of git branches in the [output_dir] Git repository.
    Each branch will be named [name] and contain a single [docker] file.
    The contents of these branches will be reset, so this should be
    only be used on an [output_dir] that is a dedicated Git repository
    for this purpose.  If [readme] is specified, the contents will be
    written to [README.md] in that branch.

    The [crunch] argument defaults to true and applies the {!Dockerfile.crunch}
    optimisation to reduce the number of layers; disable it if you really want
    more layers. *)

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

