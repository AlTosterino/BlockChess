// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract BlockChess {
    enum GameState { Active, Checkmate, Stalemate, Draw }

    struct Game {
        address player1;
        address player2;
        string moves; // Moves in PGN format (optional)
        address currentTurn; // Whose turn it is
        GameState state; // Current state of the game
        address winner; // Winner address (if applicable)
    }

    uint256 public gameCount;
    mapping(uint256 => Game) public games;

    event GameCreated(uint256 indexed gameId, address player1, address player2);
    event MoveMade(uint256 indexed gameId, address player, string move);
    event GameEnded(uint256 indexed gameId, GameState result, address winner);

    // Create a new chess game
    function createGame(address opponent) public {
        console.log("Creating game");
        require(msg.sender != opponent, "You cannot play against yourself!");

        games[gameCount] = Game({
            player1: msg.sender,
            player2: opponent,
            moves: "",
            currentTurn: msg.sender,
            state: GameState.Active,
            winner: address(0)
        });

        emit GameCreated(gameCount, msg.sender, opponent);
        gameCount++;
    }

    // Make a move
    function makeMove(uint256 gameId, string memory move) public {
        Game storage game = games[gameId];

        require(game.state == GameState.Active, "Game is not active");
        require(msg.sender == game.currentTurn, "It is not your turn");

        // Record the move
        game.moves = string(abi.encodePacked(game.moves, move, " "));

        // Switch turn
        game.currentTurn = (msg.sender == game.player1) ? game.player2 : game.player1;

        emit MoveMade(gameId, msg.sender, move);
    }

    // End the game (by either player or external validation)
    function endGame(uint256 gameId, GameState result, address winner) public {
        Game storage game = games[gameId];

        require(game.state == GameState.Active, "Game already ended");
        require(msg.sender == game.player1 || msg.sender == game.player2, "Not a participant");

        if (result == GameState.Checkmate) {
            require(winner == game.player1 || winner == game.player2, "Invalid winner address");
        } else {
            require(result == GameState.Stalemate || result == GameState.Draw, "Invalid result type");
            winner = address(0); // No winner for Stalemate or Draw
        }

        // Update game state
        game.state = result;
        game.winner = winner;

        emit GameEnded(gameId, result, winner);
    }

    // Get game information
    function getGame(uint256 gameId) public view returns (
        address player1,
        address player2,
        string memory moves,
        address currentTurn,
        GameState state,
        address winner
    ) {
        Game storage game = games[gameId];
        return (game.player1, game.player2, game.moves, game.currentTurn, game.state, game.winner);
    }
}