# <center>Makefile tutorial<center/>
## makefile基础语法
target: prerequisite,prerequisite,prerequisite...  
　　　　　　command    
　　　　　　command  
　　　　　　command...  
prerequisite:target的依赖关系,相当于你要编译文件的依赖文件  

target:目标,每个makefile文件一定要有一个target,makefile会将第一个target作为主target,依赖关系从该target的prerequisite开始寻找,找到第一个prerequisite,看是否有prerequisite对应的规则,若有则去prerequisite对应的规则下,若没有则报错,依次处理剩下的prerequisite.  

command:当target所有的prerequisite都满足时则依次执行以下的命令,command命令语法与linux命令语法相同.(注:每个command前一定要有一个tab键，不能用空格代替)

 <b>:=</b> 变量赋值  makefile := tutotial.o 将tutorial.o字符串赋值给makefile     

 $() 变量的引用  makefile := $(makefile)  将makefile变量的值赋值给makefile    

 \+ 给变量新增内容  makefile += markdown.o 在原有makefile的基础上新增字符串markdown.o  　

 SOURCES, VARIABLES为两个变量, 若SOURCES变量所含的内容是a.c b.c c.c ...那么VARIABLES := $(SOURCES:.c = .o)会将SOURCES中.c替换为.o 并将替换后的值赋给VARIABLES，即现在VARIABLES中的值为a.o b.o c.o ...  

 $(MAKE) 与make作用相同 如果在主Makefile下调用了另外一个文件夹下的Makefile,主目录Makefile调用tutorial_directory下的Makefile示例如下:
　　　　　　　　　　./PHONY:target   
　　　　　　　　　　test:   
　　　　　　　　　　　　　$(MAKE)  -C tutorial_directory　　　　　　　　　　　　　　　　　　　　　　(1)  
上例中的$(MAKE)  -C tutorial_directory 命令执行过程如下:首先进入到tutorial_directory目录，再执行make命令.  

./PHONY 伪目标 该目标不需要依赖文件 一般该目标会用来进行执行命令 (1)中的target就是伪目标  

如果文件中存在多个目标,例：  
　　　　　　　　　　./PHONY：target1 target2  
　　　　　　　　　　target1:prerequisite  
　　　　　　　　　　　　　　command　　　　　　　　　　　(2)  
　　　　　　　　　　target2:prerequisite  
　　　　　　　　　　　　　　command　　　　　　　　　　　(3)

在命令行make target会单独执行该target的依赖和目标,若make target1会执行target1的目标和依赖，在Makefile中用$(MAKE) -C 目录 target 来实现相同的功能.     

export 将变量声明为全局变量  如果主Makefile调用另一个文件夹下的Makefile并且在主Makefile中用export声明变量，那么子Makefile中也能使用该变量，在(1)中tutorial_directort目录下的Makefile能使用调用他的Makefile中用export声明的变量.

Makefile中执行shell命令 若我想执行pwd显示当前目录并赋值给TEMP,那么我可以用TEMP := $(shell pwd)


## 多个文件夹的makefile编写(针对fortran)
演示目录结构及所属文件   

         root　　- module1 module1.f90　　　　Makefile　         
           |     - module2 module2.f90       Makefile
      main.f90  
      Makefile  - mod             
                - lib  
root目录下有文件main.f90和module1, module2, mod, lib文件夹,module1目录下有文件module1.f90,module2目录下有文件module2.f90和文件夹   .在root,module1,module2目录下都有一个Makefile文件.  
main.f90引用module1.f90,module2.f90模块文件, module2.f90引用module3.f90文件.  
实现该程序编译和链接的一个办法是将module1.f90,module2.f90产生的.mod文件移动到mod文件夹下,并且将module1.f90,module2.f90产生的.o文件分别打包成.a库文件移动到lib,最后再进行链接.实现如下:  
　root Makefile:  
　　　LINK := -Llib -llibmodule1.a -llibmodule2.a  
　　　MOD := mod  
　　　INCLUDE := -J mod  
　　　libmodule1 := module1  
　　　libmodule2 := module2  
　　　main.exe:main.o    
　　　　　　　　gfortran $(LINK) -o main.exe  
　　　main.o: main.f90    
　　　　　　　　$(MAKE) lib    
　　　　　　　　gfortran   $(INCLUDE) -c main.f90    
　　　lib:    
　　　　　　　　$(MAKE) -C libmodule1  
　　　　　　　　$(MAKE) -C libmodule2  
　　　　　　　　./PHONY:lib  
　　　export INCLUDE    

module1 Makefile:  
　　　　LIBRARY := libmodule1.a  
　　　　lib:module1.o  
　　　　　　　$(AR) crs $(LIBRARY) module1.o  
　　　　　　　mv $(LIBRARY) lib  
　　　　module1.o:module1.f90
　　　　　　　gfortran $(INCLUDE) module1.f90

module2 Makefile:  
　　　　LIBRARY := libmodule2.a  
　　　　lib:module2.o  
　　　　　　　$(AR) crs $(LIBRARY) module2.o  
　　　　　　　mv $(LIBRARY) lib    
　　　　module2.o:module2.f90  
　　　　　　　gfortran $(INCLUDE) module2.f90
