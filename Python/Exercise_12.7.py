from random import randint

EMPTY = "."
b = [[EMPTY, EMPTY, EMPTY, EMPTY],[EMPTY, EMPTY, EMPTY, EMPTY],[EMPTY, EMPTY, EMPTY, EMPTY]]

def display_battlefield(board):
    print("  A B C D")
    for i in range(0,3):
        if i > 0:
            print("")
        print(i+1, end=' ')
        for j in range(0,4):
            print(board[i][j], end=' ')

def ship_count(board):
    ship_num = 0
    for row in board:
        ship_num += row.count("X")
    if ship_num == 3:
        return False
    else:
        return True

def ship_vicinity(i, j, i_list, j_list):
    count = 0
    for i_prev in i_list:
        for j_prev in j_list:
            if (i == i_prev + 1) or (i == i_prev - 1) or (j == j_prev + 1) or (j == j_prev - 1):
                count = 1
    if count == 1:
        return True
    else:
        return False

def put_ships(board):
    count = 0
    i_list = []
    j_list = []
    while ship_count(board):
        i = randint(0,2)
        j = randint(0,3)
        #print("i,j = ", i, j)
        if count > 0:
            if ship_vicinity(i, j, i_list, j_list):
                continue
        if board[i][j] == EMPTY:
            board[i][j] = "X"
            i_list.append(i)
            j_list.append(j)
            count += 1
        else:
            continue

def game_over(board):
    count = 0
    for row in board:
        if "X" in row:
            count = 1
    if count == 0:
        return True
    else:
        return False

def game(board):
    try:
        player_input = input("Which cell do you want to shoot? ")

        col = ord(player_input[0])-ord("A")
        row = int(player_input[1]) - 1

        if board[row][col] == "X":
            print("You sunk my battleship!")
            board[row].pop(col)
            board[row].insert(col, EMPTY)
        else:
            print("Miss!")

    except IndexError:
        print("Cell out of bounds!")
    except:
        print("Something went wrong!")

def main():

    display_battlefield(b)
    print("")
    put_ships(b)

    count = 1

    while True:
        game(b)
        if game_over(b):
            break
        count += 1
    print("You needed {} shots to beat the game".format(count))


main()