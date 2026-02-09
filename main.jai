#import "Basic";
#import "Random";

rl :: #import "raylib";

STEP_SIZE : s32 : 10;

WIDTH  :: 1280;
HEIGHT :: 720;

TIME_BETWEEN_GENERATIONS :: 0.05;

ALIVE_COLOR :: rl.Color.{0xFF, 0xDC, 0x00, 0xFF};
DEAD_COLOR  :: rl.Color.{0x3D, 0x99, 0x70, 0xFF};


main :: () {
    rl.InitWindow(WIDTH, HEIGHT, "Conway's Game of Life");
    defer rl.CloseWindow();

    rl.SetTargetFPS(144);

    grid : [WIDTH/STEP_SIZE][HEIGHT/STEP_SIZE]int;

    //
    // Init grid
    //
    for i: 0..grid.count-1 {
        for j: 0..grid[i].count-1 {
            if random_get_zero_to_one_open() > 0.5 {
                grid[i][j] = 1;
            } else {
                grid[i][j] = 0;
            }
        }
    }

    lifeTime := TIME_BETWEEN_GENERATIONS;

    while !rl.WindowShouldClose() {
        lifeTime -= rl.GetFrameTime();

        rl.BeginDrawing();

        rl.ClearBackground(DEAD_COLOR);

        for i: 0..grid.count-1 {
            for j: 0..grid[0].count-1 {
                if grid[i][j] == 1 {
                    rl.DrawRectangle(xx (i * STEP_SIZE), xx (j * STEP_SIZE), STEP_SIZE, STEP_SIZE, ALIVE_COLOR);
                }
            }
        }

        //
        // Update grid
        //
        if lifeTime <= 0 {
            new_grid : [WIDTH / STEP_SIZE][HEIGHT / STEP_SIZE]int;

            for i: 0..grid.count-1 {
                for j: 0..grid[0].count-1 {
                    new_grid[i][j] = 0;
                }
            }

            for i: 0..grid.count-1 {
                for j: 0..grid[0].count-1 {

                    offsets := []int.[
                        int.[-1, -1],
                        int.[-1, 0],
                        int.[-1, 1],
                        int.[0, -1],
                        int.[0, 1],
                        int.[1, -1],
                        int.[1, 0],
                        int.[1, 1],
                    ];

                    alive := 0;
                    dead  := 0;

                    for offset : offsets {
                        ni := i + offset[0];
                        nj := j + offset[1];

                        if ni < 0 || ni >= grid.count || nj < 0 || nj >= grid[0].count {
                            continue;
                        }

                        if grid[ni][nj] == 1 {
                            alive += 1;
                        } else {
                            dead += 1;
                        }
                    }

                    if grid[i][j] == 1 {
                        if alive < 2 {
                            new_grid[i][j] = 0;
                        } else if alive == 2 || alive == 3 {
                            new_grid[i][j] = 1;
                        } else if alive > 3 {
                            new_grid[i][j] = 0;
                        }
                    } else {
                        if alive == 3 {
                            new_grid[i][j] = 1;
                        }
                    }
                }
            }

            grid = new_grid;
            lifeTime = TIME_BETWEEN_GENERATIONS;
        }

        rl.EndDrawing();
    }
}

#run {
    Compiler :: #import "Compiler";
    Compiler.set_build_options_dc(.{ output_executable_name = "game" });
}
