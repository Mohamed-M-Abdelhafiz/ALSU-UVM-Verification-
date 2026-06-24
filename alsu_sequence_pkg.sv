package alsu_sequence_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alsu_seq_item_pkg::*;

    class alsu_sequence extends uvm_sequence 
                                #(alsu_seq_item);

        `uvm_object_utils(alsu_sequence)

        // How many transactions to generate
        int unsigned num_transactions = 300;

        function new(string name = "alsu_sequence");
            super.new(name);
        endfunction

        task body();
            alsu_seq_item seq_item;

            repeat(num_transactions) begin
                // Create transaction
                seq_item = alsu_seq_item::type_id::
                           create("seq_item");
                // Send to driver
                start_item(seq_item);
                // Randomize
                assert(seq_item.randomize());
                // Finish sending
                finish_item(seq_item);
            end
        endtask

    endclass

endpackage
