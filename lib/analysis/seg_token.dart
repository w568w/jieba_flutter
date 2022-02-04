 class SegToken {
   String word;

   int startOffset;

   int endOffset;


   SegToken(this.word, this.startOffset, this.endOffset);


  @override
   String toString() {
    return "[" + word + ", " + startOffset.toString() + ", " + endOffset.toString() + "]";
  }

}