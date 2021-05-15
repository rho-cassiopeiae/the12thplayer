var formationToPositions = {
  '3-1-4-2': {
    '1': {'top': 25},
    '2': {'top': 90, 'left': 60},
    '3': {'top': 90},
    '4': {'top': 90, 'right': 60},
    '5': {'top': 170},
    '6': {'top': 240, 'left': 5},
    '7': {'top': 240, 'left': 108},
    '8': {'top': 240, 'right': 108},
    '9': {'top': 240, 'right': 5},
    '10': {'top': 360, 'left': 100},
    '11': {'top': 360, 'right': 100}
  },
  '3-2-4-1': {
    '1': {'top': 25},
    '2': {'top': 90, 'left': 60},
    '3': {'top': 90},
    '4': {'top': 90, 'right': 60},
    '5': {'top': 170, 'left': 100},
    '6': {'top': 170, 'right': 100},
    '7': {'top': 255, 'left': 5},
    '8': {'top': 255, 'left': 108},
    '9': {'top': 255, 'right': 108},
    '10': {'top': 255, 'right': 5},
    '11': {'top': 360}
  },
  '3-3-1-3': {
    '1': {'top': 25},
    '2': {'top': 90, 'left': 60},
    '3': {'top': 90},
    '4': {'top': 90, 'right': 60},
    '5': {'top': 210, 'left': 60},
    '6': {'top': 170},
    '7': {'top': 210, 'right': 60},
    '8': {'top': 260},
    '9': {'top': 300, 'left': 15},
    '10': {'top': 360},
    '11': {'top': 300, 'right': 15}
  },
  '3-3-3-1': {
    '1': {'top': 25},
    '2': {'top': 90, 'left': 60},
    '3': {'top': 90},
    '4': {'top': 90, 'right': 60},
    '5': {'top': 210, 'left': 60},
    '6': {'top': 170},
    '7': {'top': 210, 'right': 60},
    '8': {'top': 260},
    '9': {'top': 300, 'left': 15},
    '10': {'top': 360},
    '11': {'top': 300, 'right': 15}
  },
  '3-4-1-2': {
    '1': {'top': 25},
    '2': {'top': 90, 'left': 60},
    '3': {'top': 90},
    '4': {'top': 90, 'right': 60},
    '5': {'top': 220, 'left': 5},
    '6': {'top': 185, 'left': 100},
    '7': {'top': 185, 'right': 100},
    '8': {'top': 220, 'right': 5},
    '9': {'top': 270},
    '10': {'top': 360, 'left': 90},
    '11': {'top': 360, 'right': 90}
  },
  '3-4-2-1': {
    '1': {'top': 25, 'radius': 22},
    '2': {'top': 90, 'left': 60, 'radius': 24},
    '3': {'top': 90, 'radius': 24},
    '4': {'top': 90, 'right': 60, 'radius': 24},
    '5': {'top': 220, 'left': 5, 'radius': 27},
    '6': {'top': 185, 'left': 100, 'radius': 26},
    '7': {'top': 185, 'right': 100, 'radius': 26},
    '8': {'top': 220, 'right': 5, 'radius': 27},
    '9': {'top': 290, 'left': 80, 'radius': 29},
    '10': {'top': 290, 'right': 80, 'radius': 29},
    '11': {'top': 360, 'radius': 31}
  },
  '3-4-3': {
    '1': {'top': 25},
    '2': {'top': 90, 'left': 60},
    '3': {'top': 90},
    '4': {'top': 90, 'right': 60},
    '5': {'top': 210, 'left': 5},
    '6': {'top': 185, 'left': 100},
    '7': {'top': 185, 'right': 100},
    '8': {'top': 210, 'right': 5},
    '9': {'top': 300, 'left': 50},
    '10': {'top': 360},
    '11': {'top': 300, 'right': 50}
  },
  '3-5-1-1': {
    '1': {'top': 25},
    '2': {'top': 90, 'left': 60},
    '3': {'top': 90},
    '4': {'top': 90, 'right': 60},
    '5': {'top': 240, 'left': 5},
    '6': {'top': 195, 'left': 80},
    '7': {'top': 160},
    '8': {'top': 195, 'right': 80},
    '9': {'top': 240, 'right': 5},
    '10': {'top': 280},
    '11': {'top': 360}
  },
  '3-5-2': {
    '1': {'top': 25},
    '2': {'top': 90, 'left': 60},
    '3': {'top': 90},
    '4': {'top': 90, 'right': 60},
    '5': {'top': 240, 'left': 5},
    '6': {'top': 195, 'left': 80},
    '7': {'top': 160},
    '8': {'top': 195, 'right': 80},
    '9': {'top': 240, 'right': 5},
    '10': {'top': 330, 'left': 90},
    '11': {'top': 330, 'right': 90}
  },
  '4-3-3': {
    '1': {'top': 25, 'radius': 22},
    '2': {'top': 130, 'left': 20, 'radius': 25},
    '3': {'top': 90, 'left': 105, 'radius': 24},
    '4': {'top': 90, 'right': 105, 'radius': 24},
    '5': {'top': 130, 'right': 20, 'radius': 25},
    '6': {'top': 240, 'left': 90, 'radius': 27},
    '7': {'top': 170, 'radius': 26},
    '8': {'top': 240, 'right': 90, 'radius': 27},
    '9': {'top': 310, 'left': 30, 'radius': 29},
    '10': {'top': 360, 'radius': 30},
    '11': {'top': 310, 'right': 30, 'radius': 29}
  },
  '4-1-2-3': {
    '1': {'top': 25},
    '2': {'top': 130, 'left': 20},
    '3': {'top': 90, 'left': 105},
    '4': {'top': 90, 'right': 105},
    '5': {'top': 130, 'right': 20},
    '6': {'top': 170},
    '7': {'top': 240, 'left': 90},
    '8': {'top': 240, 'right': 90},
    '9': {'top': 310, 'left': 30},
    '10': {'top': 360},
    '11': {'top': 310, 'right': 30}
  },
  '4-1-4-1': {
    '1': {'top': 25},
    '2': {'top': 130, 'left': 20},
    '3': {'top': 90, 'left': 105},
    '4': {'top': 90, 'right': 105},
    '5': {'top': 130, 'right': 20},
    '6': {'top': 170},
    '7': {'top': 270, 'left': 5},
    '8': {'top': 240, 'left': 100},
    '9': {'top': 240, 'right': 100},
    '10': {'top': 270, 'right': 5},
    '11': {'top': 360}
  },
  '4-5-1': {
    '1': {'top': 25},
    '2': {'top': 130, 'left': 20},
    '3': {'top': 90, 'left': 105},
    '4': {'top': 90, 'right': 105},
    '5': {'top': 130, 'right': 20},
    '6': {'top': 270, 'left': 5},
    '7': {'top': 220, 'left': 80},
    '8': {'top': 170},
    '9': {'top': 220, 'right': 80},
    '10': {'top': 270, 'right': 5},
    '11': {'top': 360}
  },
  '4-4-1-1': {
    '1': {'top': 25},
    '2': {'top': 130, 'left': 20},
    '3': {'top': 90, 'left': 105},
    '4': {'top': 90, 'right': 105},
    '5': {'top': 130, 'right': 20},
    '6': {'top': 230, 'left': 5},
    '7': {'top': 200, 'left': 100},
    '8': {'top': 200, 'right': 100},
    '9': {'top': 230, 'right': 5},
    '10': {'top': 280},
    '11': {'top': 360}
  },
  '4-2-3-1': {
    '1': {'top': 25, 'radius': 22},
    '2': {'top': 130, 'left': 20, 'radius': 25},
    '3': {'top': 90, 'left': 105, 'radius': 24},
    '4': {'top': 90, 'right': 105, 'radius': 24},
    '5': {'top': 130, 'right': 20, 'radius': 25},
    '6': {'top': 190, 'left': 100, 'radius': 26},
    '7': {'top': 190, 'right': 100, 'radius': 26},
    '8': {'top': 270, 'left': 5, 'radius': 28},
    '9': {'top': 270, 'radius': 28},
    '10': {'top': 270, 'right': 5, 'radius': 28},
    '11': {'top': 360, 'radius': 30}
  },
  '4-3-2-1': {
    '1': {'top': 25},
    '2': {'top': 130, 'left': 20},
    '3': {'top': 90, 'left': 105},
    '4': {'top': 90, 'right': 105},
    '5': {'top': 130, 'right': 20},
    '6': {'top': 210, 'left': 60},
    '7': {'top': 170},
    '8': {'top': 210, 'right': 60},
    '9': {'top': 280, 'left': 90},
    '10': {'top': 280, 'right': 90},
    '11': {'top': 360}
  },
  '4-4-2': {
    '1': {'top': 25},
    '2': {'top': 130, 'left': 20},
    '3': {'top': 90, 'left': 105},
    '4': {'top': 90, 'right': 105},
    '5': {'top': 130, 'right': 20},
    '6': {'top': 250, 'left': 5},
    '7': {'top': 200, 'left': 95},
    '8': {'top': 200, 'right': 95},
    '9': {'top': 250, 'right': 5},
    '10': {'top': 340, 'left': 90},
    '11': {'top': 340, 'right': 90}
  },
  '4-2-2-2': {
    '1': {'top': 25},
    '2': {'top': 130, 'left': 20},
    '3': {'top': 90, 'left': 105},
    '4': {'top': 90, 'right': 105},
    '5': {'top': 130, 'right': 20},
    '6': {'top': 190, 'left': 95},
    '7': {'top': 190, 'right': 95},
    '8': {'top': 270, 'left': 70},
    '9': {'top': 270, 'right': 70},
    '10': {'top': 360, 'left': 90},
    '11': {'top': 360, 'right': 90}
  },
  '4-2-4': {
    '1': {'top': 25},
    '2': {'top': 130, 'left': 20},
    '3': {'top': 90, 'left': 105},
    '4': {'top': 90, 'right': 105},
    '5': {'top': 130, 'right': 20},
    '6': {'top': 210, 'left': 95},
    '7': {'top': 210, 'right': 95},
    '8': {'top': 290, 'left': 5},
    '9': {'top': 340, 'left': 100},
    '10': {'top': 340, 'right': 100},
    '11': {'top': 290, 'right': 5}
  },
  '4-3-1-2': {
    '1': {'top': 25},
    '2': {'top': 130, 'left': 20},
    '3': {'top': 90, 'left': 105},
    '4': {'top': 90, 'right': 105},
    '5': {'top': 130, 'right': 20},
    '6': {'top': 220, 'left': 50},
    '7': {'top': 180},
    '8': {'top': 220, 'right': 50},
    '9': {'top': 270},
    '10': {'top': 350, 'left': 85},
    '11': {'top': 350, 'right': 85}
  },
  '4-1-3-2': {
    '1': {'top': 25},
    '2': {'top': 130, 'left': 20},
    '3': {'top': 90, 'left': 105},
    '4': {'top': 90, 'right': 105},
    '5': {'top': 130, 'right': 20},
    '6': {'top': 180},
    '7': {'top': 260, 'left': 50},
    '8': {'top': 260},
    '9': {'top': 260, 'right': 50},
    '10': {'top': 360, 'left': 85},
    '11': {'top': 360, 'right': 85}
  },
  '5-3-2': {
    '1': {'top': 25},
    '2': {'top': 160, 'left': 5},
    '3': {'top': 105, 'left': 65},
    '4': {'top': 90},
    '5': {'top': 105, 'right': 65},
    '6': {'top': 160, 'right': 5},
    '7': {'top': 230, 'left': 50},
    '8': {'top': 200},
    '9': {'top': 230, 'right': 50},
    '10': {'top': 330, 'left': 85},
    '11': {'top': 330, 'right': 85}
  },
  '5-2-3': {
    '1': {'top': 25},
    '2': {'top': 160, 'left': 5},
    '3': {'top': 105, 'left': 65},
    '4': {'top': 90},
    '5': {'top': 105, 'right': 65},
    '6': {'top': 160, 'right': 5},
    '7': {'top': 200, 'left': 95},
    '8': {'top': 200, 'right': 95},
    '9': {'top': 290, 'left': 50},
    '10': {'top': 340},
    '11': {'top': 290, 'right': 50}
  },
  '5-4-1': {
    '1': {'top': 25},
    '2': {'top': 160, 'left': 5},
    '3': {'top': 105, 'left': 65},
    '4': {'top': 90},
    '5': {'top': 105, 'right': 65},
    '6': {'top': 160, 'right': 5},
    '7': {'top': 250, 'left': 10},
    '8': {'top': 200, 'left': 95},
    '9': {'top': 200, 'right': 95},
    '10': {'top': 250, 'right': 10},
    '11': {'top': 340}
  }
};