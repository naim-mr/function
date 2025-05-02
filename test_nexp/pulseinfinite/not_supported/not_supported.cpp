/* Pulse-inf: false negative: no support for infinite goto loops */
void simple_goto_not_terminate(int y) {
 re:
  y++;
  goto re;
}

// pulse-inf ok no loop
void simple_goto_terminate(int y) {
  y++;
  goto end;
 end:
  return;
}

/* pulse-inf: Able to flag bug */
void conditional_goto_not_terminate(int y) {
 re:
  if (y == 100)
    goto re;
  else
    return;
}



/* pulse-inf: Able to flag bug */
void conditional_goto_not_terminate(int y) {
 re:
  if (y == 100)
    goto re;
  else
    return;
}


/* pulse-inf: FALSE NEGATIVE (no goto support) */
void twovars_goto_not_terminate(int y) {
  int z = y;
  int x = 0;
 label:
  x = 42;
  goto label;
}




/* pulse-inf: works good */
void loop_pointer_terminate(int *x, int y) {
  int *z = x;
  //int y = 1;
  if (x != &y)
    while (y < 100) {
      y++;
      (*z)--;
    }
}



/* pulse-inf: works good */
void loop_pointer_non_terminate(int *x, int y) {
  int *z = x;
  //int y = 1;
  if (x == &y)
    while (y < 100) {
      y++;
      (*z)--;
    }
}



/* pulse-inf: works good */
void var_goto_terminates(int y) {
  int x = 42;
  goto end;
  x++;
 end:
  return;
}


/* pulse-inf: FP due to Pulse computing arithmetic on Q rather than BV */
void loop_signedarith_terminate(int y) {
  while (y > 0x7fffffff) {
    y++;
    y--;
  }
  return;
}



/* pulse-inf: FP due to Pulse computing arithmetic on Q rather than BV */
void goto_signedarith_terminate(int y) {
 re:
  if (y > 0x7fffffffffffffff)
    goto re;
  else
    return;
}


/* pulse-inf: False negative -- maybe augment the numiters in pulseinf config */
// From: Gupta POPL 2008 - "Proving non-termination"
int bsearch_non_terminate_gupta08(int a[], int k,
				  unsigned int lo,
				  unsigned int hi) {
  unsigned int mid;
  
  while (lo < hi) {
    mid = (lo + hi) / 2;
    if (a[mid] < k) {
      lo = mid + 1;
    } else if (a[mid] > k) {
      hi = mid - 1;
    } else {
      return mid;
    }
  }
  return -1;
}


/* pulseinf: works fine - no bug detected */
// Cook et al. 2006 - TERMINATOR fails to prove termination
typedef struct  s_list{
  int		value;
  struct s_list *next;
}		list_t;

/* pulse-inf: works good, no bug */
static void
list_iter_terminate_cook06(list_t *p) {
  int tot = 0;
  do {
    tot += p->value;
    p = p->next;
  }
  while (p != 0);
}




/* pulse-inf: works good, no bug */
static void
list_iter_terminate_cook06_variant(list_t *p) {
  int tot = 0;
  while (p != 0) {
    tot += p->value;
    p = p->next;
  }
}



/* pulse-inf: works good - no bug */
static void
list_iter_terminate_cook06_variant2(list_t *p) {
  int tot;
  for (tot = 0; p != 0; p = p->next) {
    tot += p->value;
  }
} 

#include <stdlib.h>

/* pulse-inf: works good! no bug */

int benchmark_terminate_nondet_cook06()

{
  int x = __VERIFIER_nondet_int();
  int y = __VERIFIER_nondet_int();

  int * p = &y;
  int * q = &x;
  bool b = true;
  
  while (x<100 && 100<y && b)
    {
      if (p==q) {
	int k = Ack(__VERIFIER_nondet_int(),__VERIFIER_nondet_int());
	(*p)++;
	while((k--)>100)
	  {
	    if (__VERIFIER_nondet_int()) {p = &y;}
	    if (__VERIFIER_nondet_int()) {p = &x;}
	    if (!b) {k++;}
	  }
      } else {
	(*q)--;
	(*p)--;
	if (__VERIFIER_nondet_int()) {p = &y;}
	if (__VERIFIER_nondet_int()) {p = &x;}
      }
      b = __VERIFIER_nondet_int();
    }
  return (0);
}




/* Harris et al. "Alternation for Termination (SAS 2010) - Terminating program */
//#include <stdlib.h>
//int	nondet() { return (rand()); }
void	foo(int *x) {
  (*x)--;
}

/* Pulse-inf: FP */
void interproc_terminating_harris10(int x) {
  while (x > 0)
    foo(&x);
}

/* Derived from Harris'10 - Pulse-inf: FP! */
void interproc_terminating_harris10_cond(int x) {
  while (x > 0)
    {
      if (nondet()) foo(&x);
      else foo(&x);
    }
}



// Example with array - no manifest bug
void array_iter_terminate(int array[])
{
  unsigned int i = 0;
  while (array[i] != 0) {
    array[i] = 42;
    i++;
  }
}


// Example with two arrays - no manifest bug
void array2_iter_terminate(int array1[], int array2[])
{
  unsigned int i = 0;
  while (array1[i] != 0) {
    array2[i] = 42;
    i++;
  }
}

// Example with array and non-termination
/* Pulse-inf: unable to find bug (with default widen threshold=3) */
void array_iter_nonterminate(int array[], int len)
{
  int i = 0;
  while (i < len) {
    array[i] = 42;
    if (i > 10)
      i = 0;
    i++;
  }
}

// Iterate over an array - no bug
/* Pulse-Inf: works good */
void iterate_arraysize_terminate(int array[256])
{
  unsigned int i = 0;
  while (i < (sizeof(*array) / sizeof(array[0]))) {
    array[i] = i;
    i++;
  }  
}

// Iterate over an array using a bitmask to compute array value
/* Pulse-Inf: no bug - works good */
void iterate_bitmask_terminate(int array[256], int len)
{
  unsigned int i = 0;
  while (i < len) {
    array[i] = (i & (~7));
    i++;
  }  
}

// Iterate over an array using a bitmask to compute array index
/* Pulse-Inf: no bug - works good */
void iterate_bitmask2_terminate(int array[256], int len)
{
  unsigned int i = 0;
  unsigned int j = 0;
  while (i < len) {
    j = (i & (~7));
    array[j] = i;
    i++;
  }  
}

// Iterate over an array using a bitmask leading to a non-termination
/* Pulse-inf: able to find bug */
void iterate_bitmask_nonterminate(int array[256], unsigned int len)
{
  unsigned int i = 0;
  while (i < len) {
    i = (i & (~7));
    array[i] = i;
    i++;
  }  
}

// Iterate over an array using a bitshift to compute array index leading to a non-termination
/* Pulse-inf: false negative. Unable to reason about integer overflow */
void iterate_bitshift_nonterminate(int array[256])
{
  unsigned int i = 1;
  while (i != 0)
    {
      array[i] = i;
      i = i << 1;
    }  
}

// Iterate over an array using a bitshift to compute array index
/* Pulse-inf: no bug - good */
void iterate_bitshift_terminate(int array[256], int len)
{
  unsigned int i = 1;
  while (i < len) {
    array[i] = i;
    i = i << 1;
  }  
}

// Iterate over an array using a bitshift to compute array index
/* Pulse-inf: no bug - good */
void iterate_bitshift_terminate(int array[256], unsigned char i)
{
  while (i != 0) {
    array[i] = i;
    i = i >> 1;
  }  
}

// Integer test computing a condition that will never be true
/* Pulse-Inf: false negative: unable to reason about integer underflow */
void iterate_intoverflow_nonterminate(int len)
{
  unsigned int i = 0xFFFFFFFF;
  while (i != 0)
    i -= 2;
}


// Iterate over an array using a modulo arithmetic leading to a bug
/* Pulse-infinite: false negative: unable to reason about unbounded index stuttering in the loop */
/* To verify: this should work even with low widen threshold */
void iterate_modulus_nonterminate(int array[256], unsigned int len, unsigned int i)
{
  //unsigned int i = 0;
  while (i < len) {
    i = i % 2;
    array[i] = i;
    i++;
  }  
}


/* From: zlib */
/* Iterate computing a crc value - terminates no bug */
/* Pulse-inf: no bug - good */
#define W 8
#define N 5

static unsigned int crc_braid_table[W][256];
static unsigned int crc_braid_big_table[W][256];

void iterate_crc_terminate()
{
  unsigned int k;
  unsigned long crc0 = 0xFFFFFFFF, crc1 = 0, crc2 = 0, crc3 = 0, crc4 = 0, crc5 = 0;
  unsigned short word0 = 6, word1 = 1, word2 = 2, word3 = 3, word4 = 4, word5 = 5;
  
  for (k = 1; k < W; k++) {
    crc0 ^= crc_braid_table[k][(word0 >> (k << 3)) & 0xff];
    crc1 ^= crc_braid_table[k][(word1 >> (k << 3)) & 0xff];
    crc2 ^= crc_braid_table[k][(word2 >> (k << 3)) & 0xff];
    crc3 ^= crc_braid_table[k][(word3 >> (k << 3)) & 0xff];
    crc4 ^= crc_braid_table[k][(word4 >> (k << 3)) & 0xff];
    crc5 ^= crc_braid_table[k][(word5 >> (k << 3)) & 0xff];
  }
}


