int columns = 5;
int min_column_length;
int max_column_length;
int balls = 4;
boolean game_start = false;
int paddle_width;
int brick_width;
int brick_height = 20;
int total_score;
int max_score = 0;
boolean game_over;
Ball ball;
Paddle paddle;
ArrayList bricks = new ArrayList<Brick>();


void setup(){
 size(640, 480);
 background(255, 255, 255);
 smooth();
 noCursor();
 ball = new Ball(width/2, height-25, 10.0);//
 paddle = new Paddle((width/2)+5, height-20, 20);
 game_over = false;
 total_score = 0;
 min_column_length = 3;
 max_column_length = int((0.55 * height)/brick_height);
 paddle_width = width/5;
 brick_width = (width/columns);
 
 for (int i = 0; i < columns; i++){
   int brick_count = int(random(min_column_length, max_column_length)); 
   for (int j = 0; j < brick_count; j++){
     Brick brick = new Brick(true, (i*brick_width)+5, j*(brick_height+5));
     brick.brick_colour(int(random(0, 4)));
     max_score += brick.getscore(); //calculate maximum possible score, used to test for win condition
     bricks.add(brick);
     
   }
 }
 
}

void draw(){
  background(255);
  
  if (!game_start && !game_over){
    PFont start_text = createFont("Arial",30,true);
    textFont(start_text);
    fill(0, 255, 0);
    textAlign(CENTER);
    text("Left click to start", width/2, height*.75);
  }

  if (game_over){
    PFont game_over_text = createFont("Arial",30,true);
    textFont(game_over_text);
    fill(255, 0, 0);
    textAlign(CENTER);
    text("Game Over", width/2, height/2);
    text("Total Score: " + total_score, width/2, (height/2) + 30);
  }
  else if (total_score == max_score){//if maximum score is reached ie. all bricks broken
    PFont win_text = createFont("Arial",30,true);
    textFont(win_text);
    fill(0, 0, 255);
    textAlign(CENTER);
    text("You Win!", width/2, height/2);
    text("Total Score: " + total_score, width/2, (height/2) + 30);
  }
  else{
    
    PFont game_text = createFont("Arial",15,true);
    textFont(game_text);
    fill(255, 0, 0);
    text("Score: " + total_score, 50, height-20);
    text("Balls left: " + balls, width-50, height-20);
    for (int b = 0; b < bricks.size(); b++){
      Brick brick = (Brick) bricks.get(b);
      brick.ball_touch(ball);
      brick.display();
    }
    ball.draw_ball();
    paddle.draw_paddle();
    ball.update();
    paddle.update();
    ball.checkCollisions();
    paddle.ball_touch(ball);
  }
}

void mouseClicked(){
 game_start = true; 
}

class Brick{
  boolean active;
  float x;
  float y;
  int score;
  color c;
  
  Brick(boolean a, float xpos, float ypos){
    active = a;
    x = xpos;
    y = ypos;
  }
 
  int getscore(){
    return this.score;
  }
  
  void display(){
    if (active){
      stroke(0);
      fill(c);
    }
    else{
      noStroke();
      noFill();
    }
    rect(x, y, brick_width - 10, brick_height, 5);
  }
  
  void score_inc(){
     if (active){
       active = false;
       total_score += this.score;
     }
  }
  
  void ball_touch(Ball ball){
    //controls bounce physic from top/bottom and left/right
    if (active){//if brick hasn't been hit yet
     if (ball.x >= x && ball.x <= x+brick_width && ball.y + ball.radius > y && ball.y - ball.radius < y+brick_height){
       ball.ySpeed *= -1;
       this.score_inc();

       }
     if (ball.y > y && ball.y < y+brick_height && ball.x + ball.radius > x && ball.x - ball.radius < x+brick_width){
       ball.xSpeed *= -1;
       this.score_inc();

       }
    }
     
   }
  
  void brick_colour(int colour){
    switch(colour)
    {
      case 0:
      c = color(0, 255, 0); // green
      score = 1;
      break;
      case 1:
      c = color(255, 225, 0);//yellow
      score = 2;
      break;
      case 2:
      c = color(255, 165, 0);//orange
      score = 3;
      break;
      case 3:
      c = color(255, 0, 0); //red
      score = 4;
      break;
    }
  }
 }

class Ball{
  float x;
  float y;
  float xSpeed;
  float ySpeed;
  float ball_size;
  float radius;
  
  Ball(float xpos, float ypos, float size){
    x = xpos;
    y = ypos;
    ball_size = size;
    radius = ball_size/2;
    xSpeed = -3;//control speed of ball here
    ySpeed = -3;//may glitch if speed is set high
  }
  
  void update(){
      if (game_start){
        x += xSpeed;
        y += ySpeed;
      }
      else{
        x = mouseX;//x position follows mouse when game hasnt started. Allows strategic positioning?
      }
  }
  
  void checkCollisions(){
    float r = ball_size/2;
    if ( (x<r) || (x>width-r)){
      xSpeed = -xSpeed;
    }
    if (y<r) {
      ySpeed = -ySpeed;
    }
    if (y>height-r){//if ball is lost
      game_start = false;
      if (balls > 0){
        balls--;
        x = mouseX + 25;
        y = height-25;
        xSpeed = -xSpeed;
        ySpeed = -ySpeed;
      }
      else{
        balls--;
        game_over = true;//when all balls are lost
      }
    }
  }
    
    void draw_ball(){
      fill(0);
      ellipse(x, y, ball_size, ball_size);
   }
  
}

class Paddle{
  float xpos;
  float ypos;
  float paddle_height;
  
  Paddle(float x, float y, float yn){
   xpos = x;
   ypos = y;
   paddle_height = yn;
  }
  
  void update(){
    xpos = mouseX-(paddle_width/2);
  }
  
  void draw_paddle(){
    fill(128, 128, 128);
    stroke(0);
    rect(xpos, ypos, paddle_width, paddle_height, 10);
  }
  
  void ball_touch(Ball ball){
    //controls top/bottom and left/right bounce
     if (ball.x >= xpos && ball.x <= xpos+brick_width && ball.y + ball.radius > ypos && ball.y - ball.radius < ypos+brick_height){
       ball.ySpeed *= -1;
       }
     if (ball.y > ypos && ball.y < ypos+brick_height && ball.x + ball.radius > xpos && ball.x - ball.radius < xpos+brick_width){
       ball.xSpeed *= -1;
       }
     }

}