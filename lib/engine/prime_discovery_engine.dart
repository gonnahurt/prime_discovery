import 'dart:math';
import 'dart:io';

class PrimeDiscoveryEngine {
    
    final List<BigInt> megaPrimes = List<BigInt>.filled(10, BigInt.zero);
    final List<int> miniPrimes = List<int>.filled(20, 0);
    final initialPrimes = List<int>.of([2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199], growable: false);
    int initPrime = 0;
    final miniPrimeWalk = List<int>.of([2,4,2,2], growable: false); 
    int miniWalker = 0;
    int lastMini = 3;
    final primeWalk = List<int>.of([10,2,10,2,4,2,4,6,2,6,4,2,4,6,6,2,6,4,2,6,4,6,8,4,2,4,2,4,8,6,4,6,2,4,6,2,6,6,4,2,4,6,2,6,4,2,4,2], growable: false); 
    int primeWalker = 0;
    int lastWalker = 47;
    bool isPrime = true;
    
void discoverPrimes() {
    print('2');
    for(int primeLittle=3; primeLittle < 21; primeLittle += 2){
        while (primeLittle > initialPrimes[initPrime] && isPrime){
            if (primeLittle % initialPrimes[initPrime] == 0) {
                //print('Candidate $primeLittle is not prime');
                initPrime = 0;
                isPrime = false;
            }
            else{
                initPrime++;
            }
        }
        if (isPrime) {
            //add to list of primes
            //stdout.write('$primeLittle, ');
            print('$primeLittle, ');
        }
        else{
            isPrime = true;
            initPrime = 0;
        }
        //add to list
       
        initPrime = 0;
    }

    bool firstRun = true;
    for(int primeSmall = 21; primeSmall < 199; primeSmall += miniPrimeWalk[miniWalker]){
        int rootSmall = sqrt(primeSmall).floor();
        while (rootSmall >= initialPrimes[initPrime] && isPrime){
            if (primeSmall % initialPrimes[initPrime] == 0) {
                        //print('$primeSmall divides evenly by ${initialPrimes[initPrime]}');
                        //print('Candidate $primeSmall is not prime');
                        initPrime = 0;
                        isPrime = false;
            }
            else{
                initPrime++;
                }
        } //while
            if (isPrime) {
                //add to list of primes
                //stdout.write('$primeSmall, ');
                print('$primeSmall, ');
                initPrime = 0;
            }
            else{
                isPrime = true;
                initPrime = 0;
            }
            //primeSmall += 2;
            
                //add to list     
        if (!firstRun){
            if(miniWalker < 3){
                miniWalker++;
            }
            else{
                miniWalker = 0;
            }
        }
        firstRun = false;   
    }

   /*  for(int primeAverage = 199; primeAverage < 9223372036854775807; primeAverage += 0){

    } */

    /* for(int primeMega = 9223372036854775807, primeMega > 9223372036854775807; primeprimeAverage += 0){
        
    }*/
} 
}