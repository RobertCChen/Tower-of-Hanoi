int numDisks = 3; 
int maxDisks = 20;
ArrayList<ArrayList<Integer>> towers = new ArrayList<ArrayList<Integer>>(3); // towers 0, 1, and 2 each store the disks it has


int moves = 0;
boolean autosolve = false;
int autoSpeed = -1; // speed of autosolving
int insIndex = 0; // instruction index for autosolving

int selectedDisk = -1; // stores rank of selected disk (1 for smallest, numDisks - 1 for largest)
int origSelectedTower = -1; // stores which tower selected disk was originally from - used to check if a move was made
int selectedTower = -1; // stores which tower is being selected (where disk may be placed)
int buttonHover = -1; // 1 for plus, 2 for minus, 3 for undo, 4 for restart, 5 for solve


// full set of instructions to solve from
ArrayList<Instruction> instructions = new ArrayList<Instruction>();

// stores player move history for undoing
ArrayList<Instruction> playerMoves = new ArrayList<Instruction>();

// represents an instruction to move top disk of one tower to another
class Instruction {
  int from, to;
 
  Instruction(int f, int t) {
    from = f;
    to = t;
  }
}

void setup() {
    size(600, 400);
    rectMode(CENTER);
    initTowers(numDisks);
}

void draw() {
    drawBackground();
    drawTowers();
    
    // autosolve
    if (autosolve && (autoSpeed > 60 || frameCount % (60 / autoSpeed) == 0)) {
        if (insIndex < instructions.size()) {
            Instruction ins = instructions.get(insIndex);
            moveDisk(ins.from, ins.to);
            insIndex++;
            moves++;
        }
        if (autoSpeed > 60) {
            for (int i = 0; i < (round(autoSpeed/60) - 1) && (insIndex < instructions.size()); i++) {
                Instruction ins = instructions.get(insIndex);
                moveDisk(ins.from, ins.to);
                insIndex++;
                moves++;
            }
        }
    }
    
    // moving a disk with mouse
    if (selectedDisk != -1 && !autosolve) {
        fill(diskColor(selectedDisk));
        rect(mouseX, mouseY, selectedDisk * 20, 10, 5); // selected disk follows mouse
        moveDisk(selectedTower, int(mouseX / (width/3))); // move from previous selected tower to new selected tower
    }
    
    // check if win
    if (win()) {
        fill(0);
        textSize(32);
        textAlign(CENTER, TOP);
        text("You Win!", width/2, 50);
    }
}

void initTowers(int n) {
    towers.clear();
    for (int i = 0; i < 3; i++) {
        towers.add(new ArrayList<Integer>());
    }
    for (int i = 0; i < n; i++) {
        towers.get(0).add(n - i);
    }
    
    playerMoves.clear();
    instructions.clear();
    insIndex = 0;
    moves = 0;
    autosolve = false;
    selectedTower = -1;
    origSelectedTower = -1;
    selectedDisk = -1;
}

void drawBackground() {
    background(255); // white
    
    // draw three towers/rods
    fill(102, 51, 0); // brown
    noStroke();
    rect(width / 6, 350, 180, 10, 5);
    rect(width / 6, 250, 10, 200, 5);
    rect(width / 2, 350, 180, 10, 5);
    rect(width / 2, 250, 10, 200, 5);
    rect(width * 5 / 6, 350, 180, 10, 5);
    rect(width * 5 / 6, 250, 10, 200, 5);
    
    // draw buttons
    buttonHover = -1;
    fill(200);
    if (abs(mouseX - 97) < 25/2 && abs(mouseY - 24) < 25/2) {
        fill(100);
        buttonHover = 1;
    }
    rect(97, 24, 25, 25, 5);
    fill(200);
    if (abs(mouseX - 126) < 25/2 && abs(mouseY - 24) < 25/2) {
        fill(100);
        buttonHover = 2;
    }
    rect(126, 24, 25, 25, 5);
    fill(200);
    if (abs(mouseX - 374) < 70/2 && abs(mouseY - 24) < 25/2) {
        fill(100);
        buttonHover = 3;
    }
    rect(374, 24, 70, 25, 5);
    fill(200);
    if (abs(mouseX - 458) < 70/2 && abs(mouseY - 24) < 25/2) {
        fill(100);
        buttonHover = 4;
    }
    rect(458, 24, 70, 25, 5);
    fill(200);
    if (abs(mouseX - 542) < 70/2 && abs(mouseY - 24) < 25/2) {
        fill(100);
        buttonHover = 5;
    }
    rect(542, 24, 70, 25, 5);

    // draw text
    textAlign(LEFT);
    textSize(16);
    fill(0);
    text("Disks: " + numDisks, 10, 30);
    text("+", 92, 30);
    text("-", 124, 30);
    text("Moves: " + moves, 150, 30);
    text("Undo", 354, 30);
    text("Restart", 430, 30);
    if (!autosolve) {
        text("Solve!", 520, 30);
    } else {
        text("Faster", 520, 30);
        textSize(10);
        text("Speed: " + autoSpeed, 510, 48);
        textSize(16);
    }
    
    text("Hotkeys: + | - | U | R | S", 10, 385);
    text("Minimum moves: " + (int)(pow(2, numDisks) - 1), 400, 385);
}

void drawTowers() {
    // draw disks for tower 0
    int disksBelow = 0;
    for (int i : towers.get(0)) {
        fill(diskColor(i));
        if (i == selectedDisk) {
            fill(diskColor(i), diskColor(i), diskColor(i), 150); // semi-transparent
        }
        rect(width / 6, 340 - disksBelow * 10, i * 20, 10, 5);
        disksBelow++;
    }
    // draw disks for tower 1
    disksBelow = 0;
    for (int i : towers.get(1)) {
        fill(diskColor(i));
        if (i == selectedDisk) {
            fill(diskColor(i), diskColor(i), diskColor(i), 150); // semi-transparent
        }
        rect(width / 2, 340 - disksBelow * 10, i * 20, 10, 5);
        disksBelow++;
    }
    // draw disks for tower 2
    disksBelow = 0;
    for (int i : towers.get(2)) {
        fill(diskColor(i));
        if (i == selectedDisk) {
            fill(diskColor(i), diskColor(i), diskColor(i), 150); // semi-transparent
        }
        rect(width * 5 / 6, 340 - disksBelow * 10, i * 20, 10, 5);
        disksBelow++;
    }
}

void keyPressed() {
    if(key == 'r') {
        initTowers(numDisks);
    }
    else if (key == '-' && numDisks > 1 && !started()) {
        numDisks--;
        initTowers(numDisks);
    }
    // '=' is the key for +
    else if ((key == '=' || key == '+') && numDisks < maxDisks && !started()) {
        numDisks++;
        initTowers(numDisks);
    }
    else if (key == 's' && !win()) {
        solve();
    }
    else if (key == 'u') {
        undoMove();
    }
}

void moveDisk(int from, int to) {
    if (from == to || (topDisk(to) < topDisk(from) && topDisk(to) != -1)) return;
    selectedTower = int(mouseX / (width/3));
    addTop(to, topDisk(from));
    removeTop(from);
}

void addTop(int tower, int disk) {
    towers.get(tower).add(disk);
}

// removes top disk from tower
void removeTop(int tower) {
    towers.get(tower).remove(towers.get(tower).size() - 1);
}

// returns rank of top disk of tower, -1 if no disks on tower
int topDisk(int tower) {
    if (towers.get(tower).size() == 0) {
        return -1;
    }
    return towers.get(tower).get(towers.get(tower).size() - 1);
}

void mousePressed() {
    // clicking the buttons
    if (buttonHover != -1) {
        if (buttonHover == 1 && numDisks < maxDisks && !started()) {
            numDisks++;
            initTowers(numDisks);
        } else if (buttonHover == 2 && numDisks > 1 && !started()) {
            numDisks--;
            initTowers(numDisks);
        } else if (buttonHover == 3) {
            undoMove();
        } else if (buttonHover == 4) {
            initTowers(numDisks);
        } else if (buttonHover == 5 && !win()) {
            solve();
        }
        return;
    }
    
    if (autosolve || win()) return;
    
    // selecting a disk from a tower
    if (mouseX  < width/3) {
        selectedDisk = topDisk(0);
    } else if (mouseX  < width/3 * 2) {
        selectedDisk = topDisk(1);
    } else {
        selectedDisk = topDisk(2);
    }
    
    // set selectedTower and origSelectedTower if tower has disks and not clicking button
    if (towers.get(int(mouseX / (width/3))).size() != 0 && buttonHover == -1) {
        selectedTower = int(mouseX / (width/3));
        origSelectedTower = int(mouseX / (width/3));
    }
    
}

void mouseReleased() {
    // check if move was made
    if (selectedTower != origSelectedTower && !autosolve) {
        moves++;
        playerMoves.add(new Instruction(origSelectedTower, selectedTower));
    }
    selectedTower = -1;
    origSelectedTower = -1;
    selectedDisk = -1;
}

// color of disk given rank
float diskColor(int rank) {
    return (255 * rank / 2) % 255;
}

// started if not all disk are on first tower
boolean started() {
    return towers.get(1).size() != 0 || towers.get(2).size() != 0;
}

// win if first two towers are empty and not in process of moving a disk
boolean win() {
    return towers.get(0).size() == 0 && towers.get(1).size() == 0 && origSelectedTower == -1;
}

// undo the last move
void undoMove() {
    if (playerMoves.size() != 0) {
        Instruction ins = playerMoves.get(playerMoves.size() - 1);
        playerMoves.remove(playerMoves.size() - 1);
        addTop(ins.from, topDisk(ins.to));
        removeTop(ins.to);
        moves--;
    }
}

// when solve button clicked, autosolve or increase speed
void solve() {
    if (!autosolve) {
        initTowers(numDisks);
        getInstructions(numDisks, 0, 1, 2); // gets instructions
        autosolve = true;
        autoSpeed = 1;
    } else {
        autoSpeed *= 2;
    }
}


// gets list of instructions to solve
void getInstructions(int disks, int from, int aux, int to) {
    if (disks == 1) {
        instructions.add(new Instruction(from, to));
        return;
    }
    getInstructions(disks - 1, from, to, aux);
    getInstructions(1, from, aux, to);
    getInstructions(disks - 1, aux, from, to);
}