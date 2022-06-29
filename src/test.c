#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void *new_packet () {
    return malloc(10240);
}

struct freelist {
    void *list[100000];
    uint64_t nfree;
};

void freelist_init (struct freelist *fl) {
    fl->nfree = 0;
    do {
        fl->list[fl->nfree++] = new_packet();
    } while (fl->nfree < 100000);
}

void *allocate (struct freelist *fl) {
    return fl->list[--fl->nfree];
}

void freep (struct freelist *fl, void *p) {
    fl->list[fl->nfree++] = p;
}

struct link {
    void *packets[1024];
    unsigned int read, write;
    uint64_t* rxpackets;
    uint64_t* txpackets;
};

void link_init (struct link *l) {
    l->read = 0;
    l->write = 0;
    l->rxpackets = malloc(sizeof (uint64_t));
    l->txpackets = malloc(sizeof (uint64_t));
}

int empty (struct link *l) {
    return l->read == l->write;
}

void *receive (struct link *l) {
    void *p = l->packets[l->read];
    l->read = (l->read + 1) & (1024-1);
    l->rxpackets[0]++;
    return p;
}

void transmit (struct link *l, void *p) {
    l->packets[l->write] = p;
    l->write = (l->write + 1) & (1024 - 1);
    l->txpackets[0]++;
}

void __attribute__ ((noinline)) pull (struct freelist *fl, struct link *l) {
    for (int i=0; i < 100; i++)
        transmit(l, allocate(fl));
}

void __attribute__ ((noinline)) push (struct freelist *fl, struct link *l) {
    while (!empty(l))
        freep(fl, receive(l));
}

int main () {
    struct freelist fl;
    struct link l;
    freelist_init(&fl);
    link_init(&l);

    while (l.rxpackets[0] < 1000000000) {
        pull(&fl, &l);
        push(&fl, &l);
    }
    printf("Received %ld packets (fl.nfree=%ld)\n", l.rxpackets[0], fl.nfree);
}

