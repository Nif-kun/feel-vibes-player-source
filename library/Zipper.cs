using Godot;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using DotFile = System.IO.File;
using DotImage = System.Drawing.Image;

public class Zipper : Godot.Object
{

	public static void Zip(String filePath, String zipPathFull, bool overwrite = true, bool deleteDirectoryContent = false)
	{
		if (overwrite && DotFile.Exists(zipPathFull))
		{
			DotFile.Delete(zipPathFull);
		}
		ZipFile.CreateFromDirectory(filePath, zipPathFull);
		if (deleteDirectoryContent)
		{
			Array.ForEach(System.IO.Directory.GetFiles(filePath), DotFile.Delete);
		}
	}

	public static void Unzip(String zipPath, String extractPath)
	{
		ZipFile.ExtractToDirectory(zipPath, extractPath);
	}

	public static void WriteTextFile(String zipPath, String fullName, String newText, bool overwrite = true, bool create = true)
	{
		using ZipArchive zipFile = ZipFile.Open(zipPath, ZipArchiveMode.Update);
		if (zipFile.GetEntry(fullName) != null && !overwrite)
		{
			using StreamWriter streamWriter = new(zipFile.GetEntry(fullName).Open());
			streamWriter.BaseStream.Seek(0, SeekOrigin.End);
			streamWriter.WriteLine(newText);
		}
		else
		{
			if (zipFile.GetEntry(fullName) != null && overwrite)
				zipFile.GetEntry(fullName).Delete();
			if (create || overwrite)
			{
				zipFile.CreateEntry(fullName);
				using StreamWriter streamWriter = new(zipFile.GetEntry(fullName).Open());
				streamWriter.WriteLine(newText);
			}
		}
	}

	public static string ReadTextFile(String zipPath, String fullName)
	{
		using ZipArchive zipFile = ZipFile.OpenRead(zipPath);
		if (zipFile.GetEntry(fullName) != null)
		{
			ZipArchiveEntry entry = zipFile.GetEntry(fullName);
			using StreamReader streamReader = new(entry.Open());
			return streamReader.ReadToEnd();
		}
		return null;
	}

	public static Godot.Collections.Dictionary<string, ImageTexture> CollectTextureImages(String zipPath)
	{
		Godot.Collections.Dictionary<string, ImageTexture> imageTextureDictionary = new();
		using (ZipArchive zipFile = ZipFile.OpenRead(zipPath))
		{
			foreach (ZipArchiveEntry entry in zipFile.Entries)
			{
				bool isPng = entry.FullName.EndsWith(".png", StringComparison.OrdinalIgnoreCase);
				bool isJpg = entry.FullName.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase) || entry.FullName.EndsWith(".jpeg", StringComparison.OrdinalIgnoreCase);
				Image godotImage = new();
				ImageTexture imageTexture = new();
				if (isPng || isJpg)
				{
					MemoryStream memoryStream = new();
					Stream stream = entry.Open();
					DotImage dotImage = DotImage.FromStream(stream);
					if (isPng)
					{
						dotImage.Save(memoryStream, dotImage.RawFormat);
						memoryStream.Position = 0;
						godotImage.LoadPngFromBuffer(memoryStream.ToArray());
					}
					else
					{
						dotImage.Save(memoryStream, dotImage.RawFormat);
						memoryStream.Position = 0;
						godotImage.LoadJpgFromBuffer(memoryStream.ToArray());
					}
					imageTexture.CreateFromImage(godotImage);
					imageTextureDictionary.Add(entry.FullName, imageTexture);
				}
			}
			if (imageTextureDictionary.Count > 0)
			{
				return imageTextureDictionary;
			}
		}
		return null;
	}


	public static void AppendFile(String zipPath, String filePath, String fullName, bool overwrite = true, bool disregardType = false)
	{
		using ZipArchive zipFile = ZipFile.Open(zipPath, ZipArchiveMode.Update);
		string name = fullName.Substring(0, fullName.LastIndexOf("."));
		if (overwrite)
		{
			if (disregardType)
			{
				List<string> sameNameList = new();
				foreach (ZipArchiveEntry entry in zipFile.Entries) // Cannot delete directly as it can cause modify exception
				{
					if (entry.FullName.Substring(0, entry.FullName.LastIndexOf(".")) == name)
					{
						sameNameList.Add(entry.FullName);
					}
				}
				foreach (string sameName in sameNameList)
				{
					zipFile.GetEntry(sameName)?.Delete();
				}
			}
			else
			{
				zipFile.GetEntry(fullName).Delete();
			}
			zipFile.CreateEntryFromFile(filePath, fullName);
		}
		else if (zipFile.GetEntry(fullName) == null)
		{
			zipFile.CreateEntryFromFile(filePath, fullName);
		}
	}


	public static void DisposeFile(String zipPath, String fullName)
	{
		using ZipArchive zipFile = ZipFile.Open(zipPath, ZipArchiveMode.Update);
		zipFile.GetEntry(fullName)?.Delete();
	}
}
