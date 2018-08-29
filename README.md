# CS50-Final-Project-Space-Invaders

GD50
Space Invaders – Fabian edition

Skeleton code for project0 by Colton Ogden
  cogden@cs50.harvard.edu

Implementation of project0 and added features by Fabian van Dijk
  fabiancvandijk@gmail.com

Original description of project0 by Colton Ogden:
  Space Invaders was an Atari classic released in 1978 by Taito. The game pits
  the player, a lone starship, against hordes of alien creatures that slowly descend
  upon him/her, shooting bullets along the way. The player has a limited number of lives,
  where each life is the ability to take one point of damage (by either taking a bullet
  or by colliding with an alien). The original version of the game included shields the
  player could hide behind, but this version of the game doesn't require them.

Works under LÖVE2D 0.10.2

To make this into a final project for Harvard's CS50x, I (Fabian) have added several features on top of completing project0 as described in https://cs50.github.io/games/projects/0/

  1. The major feature added is the boss fight, which repeats every 5th level and becomes gradually
  more difficult. Code can be found in BossOne.lua.

  2. I upgraded the save system using Knife.serialize, to keep track of the highest level
  the player has reached (as well as the high score). This gives player a second
  measure of success: highest cleared level.

  3. The player is now able to choose a checkpoint at which to start.
  Checkpoints are set after each boss fight.

  4. Difficulty scaling based on level. On higher levels:
  a. Aliens not only move more quickly (as specified in project0) but also shoot more often
  b. BossOne moves and shoots more quickly
  c. LevelMaker spawns more rows of aliens (up to 8 rows on level 31+)

  5. I have balanced the game's difficulty curve around the boss fights, with the idea in mind that a player who likes the game will play ~25 levels (although some parts of my code will scale after that).

I have also included some new assets:
Visual: Boss_Projectile.png and boss1.png – both from public domain
Audio: bosshurt.wav, nothurt.wav and ram.wav – made with bfxr
