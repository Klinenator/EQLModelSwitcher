# EQL Model Switcher

Switch EverQuest Legends between its built-in classic/pre-Luclin and Luclin character models.

The EQL client already contains both model sets. This script changes the relevant `eqclient.ini` settings and creates a timestamped backup before each change. It does not download or replace game assets.

## Usage

Quit EQL completely before changing models, then run:

```bash
./eql-models.sh classic
./eql-models.sh luclin
./eql-models.sh status
./eql-models.sh restore
```

The script asks you to enter your EQL installation folder when it starts.

To use another EQL folder:

```bash
EQL_GAME_DIR="/path/to/EQLegends_setup" ./eql-models.sh luclin
```

Backups are stored in `eqclient-model-backups` inside the game folder.
