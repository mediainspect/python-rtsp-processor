"""
Interactive CLI for mediainspect-rtsp
Provides a simple text-based menu for user actions.
"""
import sys

def main():
    print("🖥️  mediainspect-rtsp Interactive CLI")
    while True:
        print("\nSelect an option:")
        print("1. Import mediainspect_rtsp")
        print("2. Run a demo function (if available)")
        print("3. Exit")
        choice = input("> ").strip()
        if choice == "1":
            try:
                import mediainspect_rtsp
                print("Imported mediainspect_rtsp:", mediainspect_rtsp)
            except ImportError as e:
                print("Error importing mediainspect_rtsp:", e)
        elif choice == "2":
            print("Demo function not implemented yet.")
        elif choice == "3":
            print("Goodbye!")
            sys.exit(0)
        else:
            print("Invalid option. Please try again.")

if __name__ == "__main__":
    main()
