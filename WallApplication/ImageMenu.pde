/**************************************************
 * This is used to control the background picking
 * functionality as well as saving screen shots. 
 */

class ImageMenu {
  private String[] savedImages;       //Array of all image names
  private ImagePreview[] pageImages;  //Array of all images on current page
  private int maxPageSize;            //Max number of images per page
  private int currPageCount;          //How many images to be in the current page
  private int nextPageCount;          //How many images to be in the next page
  private int pageNumber;             //How many pages (number of images / maxPageSize )
  private Button nextArrow;           //Button object that holds the next arrow on the screen
  private Button prevArrow;           //Button object that holds the prev arrow on the screen
  private boolean disPrevArrow;       //Determine if the previous arrow should be drawn or not
  private boolean disNextArrow;       //Determine if the next arrow should be drawn or not
  private PImage menuBackground;      //Image for the background of the image menu
  private int picInFocus;             //The number for the picture that is currently being selected
  
  /**************************************************
   * Default Constructor
   */
  public ImageMenu() {
    maxPageSize = 6;
    disPrevArrow = false;
    menuBackground = loadImage("MenuBack.png");
    menuBackground.resize(width,height);
    pageNumber = 1;
    loadSavedImages();
  }// End ImageMenu()
    
  /**************************************************
   * Loads all images specified in a generated file
   */
  void loadSavedImages() {     
     //Loads the data and sketch path, then runs the listFiles perl script
     String perlFile = sketchPath("listFiles.pl");
     String imageFolder = dataPath("Images");
     String param[] = { "perl", perlFile, imageFolder };
     exec(param);
          
     savedImages = loadStrings( "theFiles.fil" );
   
     //Checks if any image names were in the file to load
     if(savedImages.length <= 0) {
       print("No files to load were found\n");
       return;
     }
     
     //More then max per page, set to max if less then max
     //then set to just the number of images.
     if(savedImages.length <= maxPageSize) {
       currPageCount = savedImages.length;
       disNextArrow = false;
     } else {
       currPageCount = maxPageSize;
       disNextArrow = true;
     }
   
     //Load the first page of the menu then return
     loadImagePage(currPageCount, pageNumber);
     return;
  }// End loadSavedImages()

  /**************************************************
   * Loads one "full page" worth of images to the 
   * screen to be displayed to the user
   */
  private void loadImagePage(int pageSize, int pageCount) {
    pageImages = new ImagePreview[pageSize];
    int imageNumber = (pageCount - 1)*maxPageSize;
    picInFocus = 0;
    
    for(int i = 0; i < pageSize; i++) {
      pageImages[i] = new ImagePreview("Images/" + savedImages[imageNumber + i], i+1); 
      pageImages[i].getPImage().resize(width/3, (height/3));
    }
    
    int theMinX = (width/6);
    int theX = theMinX;
    int theY = 0;
    int perRow = 2;
    
    //Loop through the images and display them
    for(int j = 0; j <  currPageCount; j++) {
        //image(pageImages[j].getPImage(),  theX, theY);
        pageImages[j].setImageX(theX);
        pageImages[j].setImageY(theY);
        theX = theX + (width/3);
        if(((j+1)%perRow) == 0) {
          theY = theY + (height/3);
          theX = theMinX; 
        }
    }
    
    //Load arrow buttons and resize them depending on resolution of current screen compared to
    //Sage's resolution.
    PImage tempNext = loadImage("RightArrow.png");
    PImage tempPrev = loadImage("LeftArrow.png");
    tempNext.resize((tempNext.width)/((1360*6)/width), (tempNext.height)/((768*3)/height));
    tempPrev.resize((tempPrev.width)/((1360*6)/width), (tempPrev.height)/((768*3)/height));
    
    float arrowY = height/2-(tempNext.height/2);
    float arrowX = width/6;
    nextArrow = new Button(tempNext, (arrowX*5.5)-tempNext.width, arrowY);
    prevArrow = new Button(tempPrev, arrowX*0.5, arrowY);
  }// End loadImagePage()
  
  /**************************************************
   * Displays a page worth of images
   */
  void displayPage() {
    image(menuBackground,0,0);
    
    if(picInFocus != 0) {
      tint(127);
    }
    for(int i=0; i < currPageCount; i++) {
      image(pageImages[i].getPImage(), pageImages[i].getImageX(), pageImages[i].getImageY());
    }
    if(picInFocus != 0) {
      tint(255); 
    }
    
    if(picInFocus != 0) {
      ImagePreview tempPreview = pageImages[picInFocus-1];
      /*
      fill(255,255,0);
      if(picInFocus == 1) {
        rect(tempPreview.getImageX()-10, tempPreview.getImageY()-10, tempPreview.getPImage().width, tempPreview.getPImage().height);
      } else if(picInFocus == 2) {
        rect(tempPreview.getImageX()+10, tempPreview.getImageY()-10, tempPreview.getPImage().width, tempPreview.getPImage().height);
      } else if(picInFocus == 3) {
        rect(tempPreview.getImageX()-10, tempPreview.getImageY(), tempPreview.getPImage().width, tempPreview.getPImage().height);
      } else if(picInFocus == 4) {
        rect(tempPreview.getImageX()+10, tempPreview.getImageY(), tempPreview.getPImage().width, tempPreview.getPImage().height);
      } else if(picInFocus == 5) {
        rect(tempPreview.getImageX()-10, tempPreview.getImageY()+10, tempPreview.getPImage().width, tempPreview.getPImage().height);
      } else if(picInFocus == 6) {
        rect(tempPreview.getImageX()+10, tempPreview.getImageY()+10, tempPreview.getPImage().width, tempPreview.getPImage().height);
      }
      fill(0);
      */
      image(tempPreview.getPImage(), tempPreview.getImageX(), tempPreview.getImageY());
    }
    
    //Display the navigation buttons
    if(disNextArrow == true) {
      nextArrow.drawIt();
    }
    if(disPrevArrow == true) {
      prevArrow.drawIt();
    }
    
  }// End displayPage()
  
  /**************************************************
   * Checks if any touches/clicks were on any object
   * in the menu
   */ 
  void imageMenuInput(int touchX, int touchY) {
    if((nextArrow.checkBounds() == 1)&&(disNextArrow == true)) {
      //Check if the next arrow button was pressed
      nextPage();
    } else if((prevArrow.checkBounds() == 1)&&(disPrevArrow == true)) {
      //Check if the prev arrow button was pressed
      prevPage();
    } else if((touchX > 1114)&&(picInFocus != 0)) {
      newBackground = true;
      newBackgroundImage = loadImage(pageImages[picInFocus-1].getImageName());
      newBackgroundImage.resize(width,height);
      picInFocus = 0;
      clearScreen();
      image(newBackgroundImage, 0, 0);
      newBackgroundImage = null;
      newBackground = false;
      MENU_MODE = false;
    } else {
      //Check if any of the pictures were touched
      for(int i = 0; i < currPageCount; i++) {
          if(pageImages[i].isTouched(touchX, touchY) == true) {
            if(pageImages[i].getLocation() == picInFocus) {
              //Defocus the pic becuse it was touched and in focus
              pageImages[i].deFocus();
              picInFocus = 0; 
            } else {
              //Defocus the pic in focus and put in focus the image touched
              if(picInFocus != 0) {
                pageImages[picInFocus-1].deFocus();
              }
              pageImages[i].inFocus();
              picInFocus = pageImages[i].getLocation(); 
            }
          }
      } 
    }
  }// End imageMenuInput()
  
  /**************************************************
   * Sets up variables/settings for the next image page to load
   */
  private void nextPage() {
    pageNumber++; //Increase the page number
    if(pageNumber > 1) {
      disPrevArrow = true; 
    } else {
      disPrevArrow = false; 
    }

    int tempPageCount = 0;
    //If there are more images then can fit on the next page 
    if(savedImages.length > (maxPageSize * pageNumber)) {
       disNextArrow = true;
       tempPageCount = maxPageSize;
    } else if(savedImages.length == (maxPageSize * pageNumber)) {
      //If there are exactly enough images to fit on the next page
       disNextArrow = false;
       tempPageCount = maxPageSize; 
    } else if(savedImages.length < (maxPageSize * pageNumber)) {
      //If there are less images then can fit on the next page
       disNextArrow = false;
       tempPageCount = (maxPageSize - ((maxPageSize * pageNumber) - savedImages.length)); 
    }
    print("The page count: " + tempPageCount + " Page number: " + pageNumber + "\n");
    currPageCount = tempPageCount;
    loadImagePage(tempPageCount, pageNumber);
  }// End nextPage()
  
  /**************************************************
   * Sets up the variables/settings for the previous page to load
   */
  private void prevPage() {
    pageNumber--;
    if(pageNumber < 2) {
      disPrevArrow = false; 
    } else {
      disPrevArrow = true; 
    }
    disNextArrow = true;
    currPageCount = maxPageSize;
    loadImagePage(currPageCount, pageNumber);
  }// End prePage()
  
  
}// End ImageMenu {}


/**************************************************
 * Class for each image preview.
 */
class ImagePreview{
  
  private PImage thePreviewImage;
  private String imageName;
  private int menuLocation;
  private int imageXLocation;
  private int imageYLocation;
  private int movementAmt = 25;
  
  public ImagePreview(String theImageName, int theLocation) {
    this.thePreviewImage = loadImage(theImageName);
    this.imageName = theImageName;
    this.menuLocation = theLocation;
  }
  
  public boolean isTouched(int checkX, int checkY) {
    if((checkX >= imageXLocation)&&(checkX <= (imageXLocation + thePreviewImage.width))) {
      if((checkY >= imageYLocation)&&(checkY <= (imageYLocation + thePreviewImage.height))) {
        return true;  
      }
    }
    return false;
  }
  
  public int getLocation() {
    return menuLocation; 
  }
  
  public void deFocus() {
    if(this.menuLocation == 1) {
      this.imageXLocation -= movementAmt;
      this.imageYLocation -= movementAmt;
    } else if(this.menuLocation == 2) {
      this.imageXLocation += movementAmt;
      this.imageYLocation -= movementAmt;    
    } else if(this.menuLocation == 3) {
      this.imageXLocation -= movementAmt;      
    } else if(this.menuLocation == 4) {
      this.imageXLocation += movementAmt;    
    } else if(this.menuLocation == 5) {
      this.imageXLocation -= movementAmt;
      this.imageYLocation += movementAmt;      
    } else if(this.menuLocation == 6) {
      this.imageXLocation += movementAmt;
      this.imageYLocation += movementAmt;      
    }
  }

  public void inFocus() {
    if(this.menuLocation == 1) {
      this.imageXLocation += movementAmt;
      this.imageYLocation += movementAmt;
    } else if(this.menuLocation == 2) {
      this.imageXLocation -= movementAmt;
      this.imageYLocation += movementAmt;    
    } else if(this.menuLocation == 3) {
      this.imageXLocation += movementAmt;      
    } else if(this.menuLocation == 4) {
      this.imageXLocation -= movementAmt;    
    } else if(this.menuLocation == 5) {
      this.imageXLocation += movementAmt;
      this.imageYLocation -= movementAmt;      
    } else if(this.menuLocation == 6) {
      this.imageXLocation -= movementAmt;
      this.imageYLocation -= movementAmt;      
    }
  }  
     
  public PImage getPImage() {
    return thePreviewImage; 
  }
  
  public int getImageX() {
    return imageXLocation;
  }
  
  public int getImageY() {
    return imageYLocation;
  }
  
  public void setImageX(int theX) {
    this.imageXLocation = theX; 
  }
  
  public void setImageY(int theY) {
    this.imageYLocation = theY; 
  }
  
  public String getImageName() {
    return this.imageName; 
  }
  
}
