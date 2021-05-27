require "app/require.rb"


def tick args
  $game ||= Game.new({
    state: args.state,
    outputs: args.outputs,
    inputs: args.inputs,
    grid: args.grid
  })

  $game.tick() if($gtk.reloaded_files.empty?)
end
