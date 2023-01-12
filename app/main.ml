open Js_of_ocaml
open Core

module Utils = struct
  module U = Js_of_ocaml.Js.Unsafe
  module StringMap = Map.Make (String)

  let execute_request (url : string) props =
    let rec mk_req = function
      | ReqObj props ->
          U.obj (Array.of_list (List.map (fun (k, p) -> (k, mk_req p)) props))
      | ReqValue v ->
          U.inject v
    in
    U.global##fetch (U.inject url) (mk_req props)

  let entries_to_string_map entries =
    U.global ##. Array##from entries
    |> Js.to_array
    |> Array.fold_left
         (fun a e ->
           let k = e##at 0 in
           if Js.typeof k = Js.string "string" then
             StringMap.add (Js.to_string k) (Js.to_string (e##at 1)) a
           else a )
         StringMap.empty

  let make_response (body : string) =
    U.new_obj U.global ##. Response [|U.inject body|]

  let get_entries obj = U.global ##. Object##entries obj

  let log_error e = U.global##.console##error e
end

(* application/json *)
let fetch req env =
  req##text##then_ (fun body ->
      match
        Core.handle
          { env= Utils.entries_to_string_map (Utils.get_entries env)
          ; headers= Utils.entries_to_string_map req##.headers
          ; body= Js.to_string body }
      with
      | Some cmd ->
          let promise = Utils.execute_request cmd.url cmd.props in
          (promise##catch (fun e -> Utils.log_error e))##then_ (fun _ ->
              Utils.make_response "" )
      | None ->
          Utils.make_response "" )

let () = Js.export "fetch" fetch
