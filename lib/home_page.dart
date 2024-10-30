import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snake_game/blank_pixel.dart';
import 'package:snake_game/food_pixel.dart';
import 'package:snake_game/highscore_tile.dart';
import 'package:snake_game/snake_pixel.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction{UP, DOWN, LEFT, RIGHT}

class _HomePageState extends State<HomePage> {
  //grid dimensions 
  int rowSize = 10;
  int totalNumberSquares = 100;

  bool gameHasStarted = false;
  final _nameController = TextEditingController();
   //user score
  int currentScore = 0;
  //snake position 
  List<int> snakePos = [
    0,
    1,
    2
  ];


  //snake direction initially to the right
  var currentDirection = snake_Direction.RIGHT;
  //food position 
  int foodPos= 55;

  //highscres list
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocids;
  @override
  void initState() {
    letsGetDocids = getDocId();
    super.initState();
  }

  Future getDocId () async {
    await FirebaseFirestore.instance
    .collection("highscores")
    .orderBy("score",descending: true)
    .limit(3).get().then((value) => value.docs.forEach((element) {
      highscore_DocIds.add(element.reference.id);
    }));
  }
  //start game
  void startGame(){
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep snake moving
        moveSnake();

        // check if game over
        if(gameOver()){
          timer.cancel();
          //display a message to the user
          showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context){
            return  AlertDialog(
              title: Text("Game Over"),
              content: Column(
                children: [
                  Text('Your Score is: ' + currentScore.toString(),),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: 'Enter name'),
                  )
                ],
              ),
              actions: [MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                  submitScore();
                  newGame();
                },
                child: Text("Submit"),
                color: Colors.pink,
                )],
              );
            },
          );
        }
        //if snake eating food
        //eatFood();
      });
     });
  }

  void submitScore(){
    //get access to collection
    var database = FirebaseFirestore.instance;
    // add data to firebase
    database.collection("highscores").add({
      "name": _nameController.text,
      "score": currentScore
    });
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
    snakePos = [
      0,
      1,
      2
     ];
     foodPos = 55;
     currentDirection = snake_Direction.RIGHT;
     gameHasStarted = false;
     currentScore = 0;
    });
  }

  void eatFood(){
    currentScore++;
    //make sure food is not in the new position
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberSquares);
    }
  }

  void moveSnake(){
    switch (currentDirection) {
      case snake_Direction.RIGHT:{
        //if snake is at the right wall, need re-adjust
        //add a new head 
        if(snakePos.last % rowSize == 9){
        snakePos.add(snakePos.last + 1 - rowSize);
        }else{
        snakePos.add(snakePos.last + 1);
        }
      }
        
        break;
      case snake_Direction.LEFT:{
        //add a new head 
        if(snakePos.last % rowSize == 0){
        snakePos.add(snakePos.last - 1 + rowSize);
        }else{
        snakePos.add(snakePos.last - 1);
        }
      }
        
        break;
      case snake_Direction.UP:{
        //add a new head 
        if(snakePos.last < rowSize){
          snakePos.add(snakePos.last - rowSize + totalNumberSquares);
        }else {
          snakePos.add(snakePos.last - rowSize);
        }
      }
        
        break;
      case snake_Direction.DOWN:{
        //add a new head 
        if(snakePos.last + rowSize > totalNumberSquares){
          snakePos.add(snakePos.last + rowSize - totalNumberSquares);
        }else {
          snakePos.add(snakePos.last + rowSize);
        }
      }
        
        break;
      default:
    }
    //snake is eating food
    if(snakePos.last == foodPos){
      eatFood();
    }else{
       //remove a tail
        snakePos.removeAt(0);
    }
  }
//game over
  bool gameOver(){
    //game is over when snake runs into itself
    //this occurs when there is a duplicate position in the snakePos list
    
    //this list is the body of snake (no head)
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if(bodySnake.contains(snakePos.last)){
      return true;
    }else{
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    // get screen width
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screenWidth > 428 ? 428 : screenWidth,
        child: Column(
          children: [
            //high scores
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //user current score
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Current Score",
                        style: TextStyle(color: Colors.white),
                        ),
                        Text(currentScore.toString(),
                        style: const TextStyle(fontSize: 36,color: Colors.white),
                        ),
                      ],
                    ),
                  ),
      
      
      
                  //highe score
                  Expanded(
                    child: gameHasStarted ? Container() : FutureBuilder(
                      future: letsGetDocids,
                      builder: (context, snapshot){
                      return ListView.builder(
                        itemCount: highscore_DocIds.length,
                        itemBuilder: ((context, index){
                          return  HighScoreTile(documentId: highscore_DocIds[index]);
                        }),
                      );
                    }),
                  )
                ],
              )
              ),
          
          //game grid
          Expanded(
            flex: 3,
              child: GestureDetector(
                onVerticalDragUpdate: (details){
                  if(details.delta.dy >0 && currentDirection != snake_Direction.UP){
                    currentDirection = snake_Direction.DOWN;
                  }else if (details.delta.dy < 0 && currentDirection != snake_Direction.DOWN){
                    currentDirection = snake_Direction.UP;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if(details.delta.dx >0 && currentDirection != snake_Direction.LEFT){
                    currentDirection = snake_Direction.RIGHT;
                  }else if (details.delta.dx < 0 && currentDirection != snake_Direction.RIGHT){
                    currentDirection = snake_Direction.LEFT;
                  }
                },
                child: GridView.builder(
                  itemCount: totalNumberSquares,
                  physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: rowSize,), 
                itemBuilder: (context, index){
                  if(snakePos.contains(index)){
                    return const SnakePixel();
                  }else if(foodPos==index){
                    return const FoodPixel();
                  }
                  else{
                    return  const BlankPixel();
                  }
                  
                }),
              ),
              ),
      
          //play button
          Expanded(
              child: Container(
                child: Center(
                  child:MaterialButton(
                    child: Text("Play"),
                    color: gameHasStarted? Colors.grey : Colors.pink,
                    onPressed: gameHasStarted ? () {} : startGame,
                    ),
              ),
           ), ),
          ],
        ),
      ),
    );
  }
}
