defmodule GameTest do
  use ExUnit.Case
  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "letters are all lowercase with ~r sigil" do
    game = Game.new_game()
    word = Enum.join(game.letters, "")
    assert word =~ ~r/[a-z]*/u
  end

  test "letters are all lowercase with charlist" do
    game = Game.new_game()
    chars = Enum.map(game.letters, &(String.to_charlist(&1)))
    Enum.each(chars, fn(_x) -> assert ?x > 96 end)
    Enum.each(chars, fn(_x) -> assert ?x < 123 end)
  end

  test "state isn't changed for :won or :lost game" do
    for state <- [:won, :lost] do
      game = Game.new_game() |> Map.put(:game_state, state)
      assert {^game, _} = Game.make_move(game, 7)
    end
  end
end
