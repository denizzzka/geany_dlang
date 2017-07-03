module test_file;

/**
 * Test list
 *
 * This list isn't do anything
 */
enum List
{
    First,
    Second
}

/**
 * Main function
 *
 * This function used for integration testing
 *
 * Params:
 *
 * args = command line arguments
 *
 * Returns:
 *
 * Always returns zero
 */
int main(char[][] args)
{
    auto l = List.First;

    return 0;
}
