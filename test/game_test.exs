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

  test "all letters should be in lowercase" do
    game = Game.new_game()
    result = game.letters
    |> Enum.map(&(String.downcase(&1) == &1))
    |> Enum.all?(fn(_x) -> true end)
    assert result == true
  end

  test "guess is a single lowercase character" do
    game = Game.new_game("wibble")
    {game, _tally} = Game.make_move(game, "abc")
    assert game.game_state == :bad_guess
  end

  test "state isn't changed for won or lost game" do
    for state <- [:won, :lost] do
      game = Game.new_game() |> Map.put(:game_state, state)
      assert {^game, _} = Game.make_move(game, "x")
    end
  end

  test "first occurence of letter is not already used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "a")
    refute game.game_state == :already_used
  end

  test "second occurence of letter is not already used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "a")
    refute game.game_state == :already_used
    {game, _tally} = Game.make_move(game, "a")
    assert game.game_state == :already_used
  end

  test "a good guess is recognized" do
    game = Game.new_game("wibble")
    {game, _tally} = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game" do
    game = Game.new_game("wibble")
    [{"w", :good_guess},
     {"i", :good_guess},
     {"b", :good_guess},
     {"l", :good_guess},
     {"e", :won}]
    |> Enum.reduce(game, fn({guess, state}, game) ->
       {game, _tally} = Game.make_move(game, guess)
       assert game.game_state == state
       game
    end)
  end

  test "bad guess is recognized" do
    game = Game.new_game("wibble")
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "lost game is recognized" do
    game = Game.new_game("w")
    [{"a", :bad_guess, 6},
     {"b", :bad_guess, 5},
     {"c", :bad_guess, 4},
     {"d", :bad_guess, 3},
     {"e", :bad_guess, 2},
     {"f", :bad_guess, 1},
     {"g", :lost, 1}]
    |> Enum.reduce(game, fn({guess, state, turns_left}, game) ->
      {game, _tally} = Game.make_move(game, guess)
      assert game.game_state == state
      assert game.turns_left == turns_left
      game
    end)
  end

  test "reveal guessed underscores not guessed letters" do
    game = Game.new_game("house")
    {game, _tally} = Game.make_move(game, "e")
    {game, _tally} = Game.make_move(game, "h")
    {game, _tally} = Game.make_move(game, "a")
    tally = Game.tally(game)
    assert Map.fetch!(tally, :game_state) == :bad_guess
    assert Map.fetch!(tally, :turns_left) == 6
    assert Map.fetch!(tally, :letters)    == ["h", "_", "_", "_", "e"]
    assert Map.fetch!(tally, :used)       == ["a", "e", "h"]
  end
end
