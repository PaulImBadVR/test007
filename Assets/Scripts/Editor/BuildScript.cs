using UnityEditor;
using UnityEngine;

public class BuildScript
{
    public static void BuildAndroid()
    {
        Debug.Log("BuildScript.BuildAndroid is called");
        string[] scenes = { "Assets/SampleScene.unity" };
        string outputPath = "Builds/WindowsBuild.exe";
        BuildPipeline.BuildPlayer(scenes, outputPath, BuildTarget.StandaloneWindows64, BuildOptions.None);
        Debug.Log("BuildScript.BuildAndroid is exiting");
    }
}
