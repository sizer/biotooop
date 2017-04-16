import Html exposing (Html, Attribute, div, input, button, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Http
import Json.Decode as Decode


main : Program Never Model Msg
main =
  Html.program {
    init = init,
    view = view,
    update = update,
    subscriptions = subscriptions
  }

-- MODEL
type alias Model = {
  tags: List Tag
}

type alias Tag = {
  id : Int,
  name : String
}

init : (Model, Cmd Msg)
init = (Model [], Cmd.none)

-- UPDATE
type Msg
  = Search String
  | UpdateByHttpResponse (Result Http.Error (List Tag))

update : Msg -> Model -> (Model, Cmd Msg)
update msg _ =
  case msg of
    Search (_)->
      (Model [], fetchTagdata)

    UpdateByHttpResponse (Ok tags) ->
      (Model tags, Cmd.none)

    UpdateByHttpResponse (Err _) ->
      (Model [(Tag 0 "an error occured...")], Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
  let
    styles =
      style[
        ("width", "100%"),
        ("height", "40px"),
        ("padding", "10px 0"),
        ("font-size", "2em"),
        ("text-align", "center")
      ]
  in
    div [] [
      div [] [
        input [ placeholder "タグ検索", onInput Search, styles ] []
      ],
      div [] (List.map viewTagdetail model.tags)
    ]

viewTagdetail : Tag -> Html Msg
viewTagdetail tagModel =
  let
    styles =
      style[
        ("width", "100%"),
        ("height", "40px"),
        ("padding", "10px 0"),
        ("font-size", "2em"),
        ("border", "solid 2px #eeeeee")
      ]
  in
    div[ styles ][
      text tagModel.name
    ]

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- HTTP
fetchTagdata : Cmd Msg
fetchTagdata =
  let
    url = "http://localhost:5000/tags.json"
  in
    Http.send UpdateByHttpResponse(Http.get url tagListDecoder)

tagListDecoder : Decode.Decoder (List Tag)
tagListDecoder =
  Decode.list tagDecoder

tagDecoder : Decode.Decoder Tag
tagDecoder =
  Decode.map2 Tag
    (Decode.field "id" Decode.int)
    (Decode.field "name" Decode.string)
