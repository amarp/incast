import java.io.*;

class Binner {

    static int numBins = 100;
    public static void main(String[] args) {

        if (args.length < 2) {
            System.out.println("Usage: java Binner Filename Column (starting column = 0)");
	    System.exit(0);
        }

	int[] bins;
	bins = new int[numBins];
	String fileName = args[0];
        int column = Integer.parseInt(args[1]);

	for (int i = 0; i < numBins; i++) {
	    bins[i] = 0;
	}

	int numBins = 100;
	try {
	    BufferedReader in = new BufferedReader(new FileReader(fileName));
	    String str;
	    String[] result;
	    while ((str = in.readLine()) != null) {
		result = str.split(" ");
		bins[Integer.parseInt(result[column])]++;
	    }
	    
	    for (int i = 0; i < numBins; i++) {
		if (bins[i] != 0) {
		    System.out.print(i + " ");
		    System.out.println(bins[i]);
		}
	    }
	    
	} catch (IOException e) {
	    
	}
    }
	
};
