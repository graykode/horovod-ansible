#include <iostream>
#include <mpi.h>

int main(int argc, char *argv[])
{
    int numprocessors, rank, namelen;
    char processor_name[MPI_MAX_PROCESSOR_NAME];

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numprocessors);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Get_processor_name(processor_name, &namelen);

    if ( rank == 0 )
    {
        std::cout << "Processor name: " << processor_name << "\n";
    std::cout << "master (" << rank << "/" << numprocessors << ")\n";
    } else {
        std::cout << "Processor name: " << processor_name << "\n";
        std::cout << "slave  (" << rank << "/" << numprocessors << ")\n";
   }
   MPI_Finalize();
   return 0;
}