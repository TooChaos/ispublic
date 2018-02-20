class abcABC : public efg {
  bool public_method2();
public:
  void public_method1() {}
  void private_method0(); 
private:
  int private_method3();
 protected:
  const int& protecte_method4();
  class hij {
  public:
    int i;
  }
  enum {}
  class _foo1_abc: public hij {
    int i;
  } /*  */

 public:
  typedef long int my_int;
}


//
class ABC::hij::ugg
{
  int a;
}


// todo: handle this case as well
class abc::hij
/* 
ojdka;l //
class xyz
 */
// class abc
{
public:
  // class abc 
  // private:
  /*
    ;
    {}
    protected:
  */
  bool f_b(); 
  int i;
  void f_c() {int x=0;}
}




   class /*xyoz*/ abc::def {// bug 2: does not handleinline comment 
      // class def {
      //   }
/*      class def {
        }*/
      public/**/:  // bug3 : cannot handle inline comment between
                   // public and :
      int i,j;
   }
