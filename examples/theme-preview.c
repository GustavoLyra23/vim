#include <stdbool.h>
#include <stddef.h>

// Comentários verdes; texto escuro sobre um fundo branco suave.
typedef struct ListNode {
    void *payload;
    struct ListNode *next;
} ListNode;

static void list_prepend(ListNode **head, void *data, size_t size)
{
    // Amostra visual: não aloca nem modifica a lista.
    (void)head;
    (void)data;
    (void)size;
}

#define LIST_PREPEND(head, item) \
    list_prepend(head, &(item), sizeof(item))

int main(void)
{
    ListNode *head = NULL;
    int numbers[] = {5, 6};
    const char *label = "Pastel Branco";
    bool ready = true;

    LIST_PREPEND(&head, numbers);
    (void)label;
    return ready ? 0 : 1;
}
