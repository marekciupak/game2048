# Game2048

[![CI](https://github.com/marekciupak/game2048/actions/workflows/ci.yml/badge.svg)](https://github.com/marekciupak/game2048/actions/workflows/ci.yml)

Just another implementation of [2048](https://en.wikipedia.org/wiki/2048_(video_game)) game.

:tada: Specific functionalities for this implementation:

- configurable grid size,
- optional obstacles on the grid for ambitious players,
- multiplayer gameplay (you can play the same game on multiple web browser windows).

:construction: What is missing?
- the user interface is not polished and **lack of animation when sliding tiles makes it difficult to follow the game**,
- playing multiple independent games at the same time on a single server is currently not supported.

## :fast_forward: Demo

<kbd>![Sample game](docs/sample_game.gif)</kbd>

## :orange_book: Documentation

### :speech_balloon: Game rules & language used in the project

The game is played on a ***grid***.
Grid consists of ***rows*** (and ***columns***).
Each row (or column) has ***spots***.

A spot can be ***empty*** or contain an ***element*** (***obstacle*** or ***tile***).
The tiles have numbers on them.

The player's ***move*** consists in ***sliding*** the tiles in one of four ***directions*** (***left***, ***right***,
***up*** or ***down***).
Tiles slide as far as possible in the chosen direction until they are stopped by either another tile, obstacle, or the
edge of the grid.
If two tiles of the same number collide while moving, they will ***merge*** into a tile with the total value of the two
tiles that collided. The resulting tile cannot merge with another tile again in the same move.
If a move causes three consecutive tiles of the same value to slide together, the two tiles farthest along the
direction of motion will combine.

On every move, a new tile randomly appears in an empty spot on the grid with a value of `1`.

The game is ***won*** when a tile with a value of `2048` appears on the grid.
Players can not continue the game beyond that.

When no ***legal move*** can be made (the player is unable to slide any more tiles), the player ***loses*** the game.

### :rocket: Running the app locally in `dev` enviroment

1. Ensure you have installed runtimes in versions declared in [.tool-versions](.tool-versions) file.

2. Clone the repo to you local machine:

    ```shell
    git clone git@github.com:marekciupak/game2048.git
    ```

2. Setup project with `mix setup`.

3. Optionally, check everything is fine with `mix test`.

4. Start Phoenix endpoint with `mix phx.server` (or inside IEx with `iex -S mix phx.server`).

5. Now you can visit [`localhost:4000`](http://localhost:4000) from your browser (and play the game...).

### ::ship:: Docker image with `prod` release

:warning: Depending on your setup, you may need to use `sudo` to run `docker ...` commands.

Assuming, you have [Docker](https://www.docker.com/get-started/) on your machine, you can build the production release
image via the following command:

```shell
docker build . -t marekciupak_game2048
```

The app will accept env vars, for example:

```shell
$ docker run \
    --env SECRET_KEY_BASE="REALLY_LONG_SECRET" \
    --env PHX_HOST="game2048.dev" \
    --env PORT=4001 \
    marekciupak_game2048
18:06:09.670 [info] Running Game2048Web.Endpoint with cowboy 2.9.0 at :::4001 (http)
18:06:09.670 [info] Access Game2048Web.Endpoint at https://game2048.dev
```

## :scroll: Copyright and license

See the [LICENSE](LICENSE).
