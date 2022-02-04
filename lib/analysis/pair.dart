
 class Pair<K> {
   K key;
   double freq = 0.0;

   Pair(this.key, this.freq);

   @override
  String toString() {
    return "Candidate [key=" + key.toString() + ", freq=" + freq.toString() + "]";
  }

}